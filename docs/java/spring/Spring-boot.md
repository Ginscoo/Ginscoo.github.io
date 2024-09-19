
### org.springframework.boot.admin.SpringApplicationAdminMXBean
[http://baijiahao.baidu.com/s?id=1668247436055457456](http://baijiahao.baidu.com/s?id=1668247436055457456)

## 配置文件
spring配置文件后加载的配置会覆盖前一个配置。
```conf
# 环境配置 不会被spring.profiles.include覆盖
spring.profiles.active=dev
# 额外的配置
spring.profiles.include=db
```
* 加载顺序是：application.proeprties -> spring.profiles.include -> spring.profiles.active
* 配置文件生效优先级：spring.profiles.active -> spring.profiles.include -> application.proeprties
```java
// ConfigDataEnvironment # withProfiles(...)
	private ConfigDataActivationContext withProfiles(ConfigDataEnvironmentContributors contributors,
			ConfigDataActivationContext activationContext) {
		this.logger.trace("Deducing profiles from current config data environment contributors");
		Binder binder = contributors.getBinder(activationContext,
				(contributor) -> !contributor.hasConfigDataOption(ConfigData.Option.IGNORE_PROFILES),
				BinderOption.FAIL_ON_BIND_TO_INACTIVE_SOURCE);
		try {
			Set<String> additionalProfiles = new LinkedHashSet<>(this.additionalProfiles);
			additionalProfiles.addAll(getIncludedProfiles(contributors, activationContext));
			Profiles profiles = new Profiles(this.environment, binder, additionalProfiles);
			return activationContext.withProfiles(profiles);
		}
		catch (BindException ex) {
			if (ex.getCause() instanceof InactiveConfigDataAccessException) {
				throw (InactiveConfigDataAccessException) ex.getCause();
			}
			throw ex;
		}
	}
```


