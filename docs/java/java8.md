## JVM 参数
### java.security.debug - 打印JVM安全配置信息
使用方式 `-Djava.security.debug=`  可选参数如下，多个用`,`隔开

```Shell

all           turn on all debugging
access        print all checkPermission results
certpath      PKIX CertPathBuilder and
              CertPathValidator debugging
combiner      SubjectDomainCombiner debugging
gssloginconfig
              GSS LoginConfigImpl debugging
configfile    JAAS ConfigFile loading
configparser  JAAS ConfigFile parsing
jar           jar verification
logincontext  login context results
jca           JCA engine class debugging
policy        loading and granting
provider      security provider debugging
pkcs11        PKCS11 session manager debugging
pkcs11keystore
              PKCS11 KeyStore debugging
sunpkcs11     SunPKCS11 provider debugging
scl           permissions SecureClassLoader assigns
ts            timestamping

The following can be used with access:

stack         include stack trace
domain        dump all domains in context
failure       before throwing exception, dump stack
              and domain that didn't have permission

The following can be used with stack and domain:

permission=<classname>
              only dump output if specified permission
              is being checked
codebase=<URL>
              only dump output if specified codebase
              is being checked

The following can be used with provider:

engine=<engines>
              only dump output for the specified list
              of JCA engines. Supported values:
              Cipher, KeyAgreement, KeyGenerator,
              KeyPairGenerator, KeyStore, Mac,
              MessageDigest, SecureRandom, Signature.

Note: Separate multiple options with a comma

```

### java.security.egd - SecurityRandom种子生成文件

### javax.net.debug - SSL debug

使用方式 `-Djavax.net.debug=` 可选参数如下

```Shell

all            turn on all debugging
ssl            turn on ssl debugging

The following can be used with ssl:
	record       enable per-record tracing
	handshake    print each handshake message
	keygen       print key generation data
	session      print session activity
	defaultctx   print default SSL initialization
	sslctx       print SSLContext tracing
	sessioncache print session cache tracing
	keymanager   print key manager tracing
	trustmanager print trust manager tracing
	pluggability print pluggability tracing

	handshake debugging can be widened with:
	data         hex dump of each handshake message
	verbose      verbose handshake message printing

	record debugging can be widened with:
	plaintext    hex dump of record plaintext
	packet       print raw SSL/TLS packets

```

## MANIFEST.MF

* Sealed
    * Sealed: true - 包中所有的代码都必须来自同一个包

