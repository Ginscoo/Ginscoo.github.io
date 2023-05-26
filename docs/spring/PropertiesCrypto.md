## 需求背景
应用程序开发的时候，往往会存在一些敏感的配置属性
* 数据库账号、密码
* 第三方服务账号密码
* 内置加密密码
* 其他的敏感配置
对于安全性要求比较高的公司，往往不允许敏感配置以明文的方式出现。
通常做法是对这些敏感配置进行加密，然后在使用的地方进行解密。但是有一些第三方的配置可能未提供解密注入点如数据库密码，这时要实现起来就比较麻烦。有没有比较方便的方法可以自动识别并解密。
本次主要针对这个问题，解决敏感配置的加密问题

## 实现思路
* 使用已有的第三方包：如[jasypt-spring-boot
](https://github.com/ulisesbocchio/jasypt-spring-boot)
    * 这是一个针对SpringBoot项目配置进行加解密的包，可以在项目里通过引入依赖来实现。具体使用方式自行搜索
* 参考官方文档利用官方提供的扩展点自己实现
    * 实现`EnvironmentPostProcessor`
        * `EnvironmentPostProcessor`在配置文件解析后，bean创建前调用
    * 实现`BeanFactoryPostProcessor`（优先考虑）
        * `BeanFactoryPostProcessor`在配置文件解析后，bean创建前调用
        * 实现方式同`EnvironmentPostProcessor`基本一致，注入时机更靠后。

### 通过实现`EnvironmentPostProcessor`方式解决
实现`EnvironmentPostProcessor`可自定义环境配置处理逻辑。实现示例如下

```Java
    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        MutablePropertySources mutablePropertySources = environment.getPropertySources();

        for (PropertySource<?> propertySource : mutablePropertySources) {
            if (propertySource instanceof OriginTrackedMapPropertySource) {
                mutablePropertySources.replace(propertySource.getName(),
                // 实现一个包装类，动态判断
                        new PropertySourceWrapper(propertySource, initSimpleEncryptor("reduck-project")
                                , new EncryptionWrapperDetector("$ENC{", "}"))
                );
            }
        }
    }
```
`EnvironmentPostProcessor` 也可以自动扩展配置文件，如果有些项目自己在这个扩展点实现了自己的配置加载逻辑，可能就需要考虑顺序问题。这里比较推荐实现`BeanFactoryPostProcessor`，他在`EnvironmentPostProcessor`相关实例处理后调用，且在Bean创建前。可以更好满足需求。

### 通过实现`BeanFactoryPostProcessor`解决

* 实现`EncryptionBeanPostProcessor`
    * 一般`OriginTrackedMapPropertySource`是我们自定义的配置加载实例，通过一个包装类替换原先的实例

```
@RequiredArgsConstructor
public class EncryptionBeanPostProcessor implements BeanFactoryPostProcessor, Ordered {
    private final ConfigurableEnvironment environment;

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        MutablePropertySources mutablePropertySources = environment.getPropertySources();

        String secretKey = environment.getProperty("configuration.crypto.secret-key");

        if(secretKey ==  null) {
            return;
        }

        for (PropertySource<?> propertySource : mutablePropertySources) {
            if (propertySource instanceof OriginTrackedMapPropertySource) {
                mutablePropertySources.replace(propertySource.getName(),
                        new PropertySourceWrapper(propertySource
                                , new AesEncryptor(PrivateKeyFinder.getSecretKey(secretKey))
                                , new EncryptionWrapperDetector("$ENC{", "}"))
                );
            }
        }
    }

    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE - 100;
    }
}

```

* 定义一个 `PropertySource`包装类
    *  `PropertySource`只有一个方法 `public Object getProperty(String name)`，只需要实现这个方法，如果是加密配置就解密 

```Java
public class PropertySourceWrapper<T> extends PropertySource<T> {
    private final String prefix = "$ENC{";
    private final String suffix = "}";

    private final Encryptor encryptor;

    private final PropertySource<T> originalPropertySource;
    private final EncryptionWrapperDetector detector;


    public PropertySourceWrapper(PropertySource<T> originalPropertySource, Encryptor encryptor, EncryptionWrapperDetector detector) {
        super(originalPropertySource.getName(), originalPropertySource.getSource());
        this.originalPropertySource = originalPropertySource;
        this.encryptor = encryptor;
        this.detector = detector;
    }

    @Override
    public Object getProperty(String name) {
        if (originalPropertySource.containsProperty(name)) {
            Object value = originalPropertySource.getProperty(name);
            if (value != null) {
                String property = value.toString();
                if (detector.detected(property)) {
                    return encryptor.decrypt(detector.unWrapper(property));
                }
            }
        }
        return originalPropertySource.getProperty(name);
    }
}
```

* 定义一个加解密帮助类`EncryptionWrapperDetector`
    * 根据前后缀判断是否是加密属性
    * 对加密属性进行包装
    * 对加密属性去除包装
```Java
public class EncryptionWrapperDetector {
    private final String prefix;

    private final String suffix;

    public EncryptionWrapperDetector(String prefix, String suffix) {
        this.prefix = prefix;
        this.suffix = suffix;
    }

    public boolean detected(String property) {
        return property != null && property.startsWith(prefix) && property.endsWith(suffix);
    }

    public String wrapper(String property) {
        return prefix + property + suffix;
    }

    public String unWrapper(String property) {
        return property.substring(prefix.length(), property.length() - suffix.length());
    }
}
```

* 定义一个加解密类
    * 对配置文件进行加密
    * 对配置问价进行解密
```Java
public class AesEncryptor implements Encryptor {

    private final byte[] secretKey;
    private final byte[] iv = new byte[16];

    public AesEncryptor(byte[] secretKey) {
        this.secretKey = secretKey;
        System.arraycopy(secretKey, 0, iv, 0, 16);
    }

    @Override
    public String encrypt(String message) {
        return Base64.getEncoder().encodeToString(_AesUtils.encrypt(secretKey, iv, message.getBytes()));
    }

    @Override
    public String decrypt(String message) {
        return new String(_AesUtils.decrypt(secretKey, iv, Base64.getDecoder().decode(message)));
    }
}
```

* 密钥加密存储
    * 采用非对称加密方式对密钥进行加密，用公钥加密后的密钥可以直接写在配置文件中
    * 在进行解密的时候先通过内置的私钥解密获取原始加密密钥
    * 注意细节
        * 私钥存储的时候可以再进行一次加密
        * 私钥可放在META-INF路径下，通过`Classloader`获取

```Java
public class PrivateKeyFinder {
    private static final String PRIVATE_KEY_RESOURCE_LOCATION = "META-INF/configuration.crypto.private-key";
    private static final String PUBLIC_KEY_RESOURCE_LOCATION = "META-INF/configuration.crypto.public-key";
    private final byte[] keyInfo = new byte[]{
            (byte) 0xD0, (byte) 0x20, (byte) 0xDA, (byte) 0x92, (byte) 0xC8, (byte) 0x0B, (byte) 0x6D, (byte) 0x57,
            (byte) 0x48, (byte) 0x7B, (byte) 0x15, (byte) 0x3A, (byte) 0x44, (byte) 0xA0, (byte) 0x98, (byte) 0xC2,
            (byte) 0xF1, (byte) 0x6F, (byte) 0xB6, (byte) 0x09, (byte) 0x2F, (byte) 0x6D, (byte) 0x69, (byte) 0xFB,
            (byte) 0x2D, (byte) 0x02, (byte) 0x00, (byte) 0xCB, (byte) 0xBE, (byte) 0x48, (byte) 0xDD, (byte) 0xD5,
            (byte) 0x90, (byte) 0xC2, (byte) 0x95, (byte) 0x98, (byte) 0x60, (byte) 0x59, (byte) 0x24, (byte) 0xE2,
            (byte) 0xB7, (byte) 0x84, (byte) 0x12, (byte) 0x5D, (byte) 0xB9, (byte) 0xC1, (byte) 0x19, (byte) 0xFF,
            (byte) 0x4F, (byte) 0x01, (byte) 0xB9, (byte) 0xC5, (byte) 0xD8, (byte) 0xD2, (byte) 0x99, (byte) 0xEE,
            (byte) 0xAA, (byte) 0x0D, (byte) 0x59, (byte) 0xF8, (byte) 0x37, (byte) 0x49, (byte) 0x91, (byte) 0xAB
    };

    static byte[] getSecretKey(String encKey) {
        byte[] key = loadPrivateKey();
        return RsaUtils.decrypt(Base64.getDecoder().decode(encKey), new PrivateKeyFinder().decrypt(Base64.getDecoder().decode(key)));
    }

    static String generateSecretKey() {
        return Base64.getEncoder().encodeToString(RsaUtils.encrypt(new SecureRandom().generateSeed(16), Base64.getDecoder().decode(loadPublicKey())));
    }

    static String generateSecretKeyWith256() {
        return Base64.getEncoder().encodeToString(RsaUtils.encrypt(new SecureRandom().generateSeed(32), Base64.getDecoder().decode(loadPublicKey())));
    }

    @SneakyThrows
    static byte[] loadPrivateKey() {
        return loadResource(PRIVATE_KEY_RESOURCE_LOCATION);
    }

    @SneakyThrows
    static byte[] loadPublicKey() {
        return loadResource(PUBLIC_KEY_RESOURCE_LOCATION);
    }

    @SneakyThrows
    private static byte[] loadResource(String location) {
        // just lookup from current jar  path
        ClassLoader classLoader = new URLClassLoader(new URL[]{PrivateKeyFinder.class.getProtectionDomain().getCodeSource().getLocation()}, null);
//        classLoader = PrivateKeyFinder.class.getClassLoader();
        Enumeration<URL> enumeration = classLoader.getResources(location);

        // should only find one
        while (enumeration.hasMoreElements()) {
            URL url = enumeration.nextElement();
            UrlResource resource = new UrlResource(url);
            return FileCopyUtils.copyToByteArray(resource.getInputStream());
        }

        return null;
    }

    private final String CIPHER_ALGORITHM = "AES/CBC/NoPadding";
    private final String KEY_TYPE = "AES";

    @SneakyThrows
    public byte[] encrypt(byte[] data) {
        byte[] key = new byte[32];
        byte[] iv = new byte[16];
        System.arraycopy(keyInfo, 0, key, 0, 32);
        System.arraycopy(keyInfo, 32, iv, 0, 16);
        Cipher cipher = Cipher.getInstance(CIPHER_ALGORITHM);
        cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(key, KEY_TYPE), new IvParameterSpec(iv));
        return cipher.doFinal(data);
    }

    @SneakyThrows
    public byte[] decrypt(byte[] data) {
        byte[] key = new byte[32];
        byte[] iv = new byte[16];
        System.arraycopy(keyInfo, 0, key, 0, 32);
        System.arraycopy(keyInfo, 32, iv, 0, 16);

        Cipher cipher = Cipher.getInstance(CIPHER_ALGORITHM);
        cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(key, KEY_TYPE), new IvParameterSpec(iv));
        return cipher.doFinal(data);
    }
}
```

综上既可以实现敏感配置文件的加解密，同时可以保障加密密钥的安全传入