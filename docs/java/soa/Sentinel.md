```conf
        <dependency>
            <groupId>com.alibaba.csp</groupId>
            <artifactId>sentinel-core</artifactId>
<!--            <version>1.8.6</version>-->
            <version>2.0.0-alpha</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba.csp</groupId>
            <artifactId>sentinel-annotation-aspectj</artifactId>
<!--            <version>1.8.6</version>-->
            <version>2.0.0-alpha</version>
        </dependency>
```

```Java
@Configuration
public class AopConfiguration {

    @Bean
    public SentinelResourceAspect sentinelResourceAspect() {
        return new SentinelResourceAspect();
    }
}
```

```Java
FlowRule rule = new FlowRule();
rule.setResource("*");
rule.setGrade(RuleConstant.FLOW_GRADE_QPS);
rule.setCount(100);
FlowRuleManager.loadRules(Collections.singletonList(rule));
```

```Java
DegradeRule rule = new DegradeRule();
rule.setResource("*");
rule.setGrade(RuleConstant.DEGRADE_GRADE_EXCEPTION_RATIO);
rule.setCount(0.5);
rule.setTimeWindow(5);
DegradeRuleManager.loadRules(Collections.singletonList(rule));
```