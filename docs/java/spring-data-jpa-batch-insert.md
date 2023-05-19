### 开启配置

```Config
# 统计生成SQL执行情况
spring.jpa.properties.hibernate.generate_statistics=true
# 开启批量插入
spring.jpa.properties.hibernate.jdbc.batch_size=500
spring.jpa.properties.hibernate.order_inserts=true
```

## 代码示例
org.springframework.data.jpa.repository.JpaRepository 提供的 saveAll() 方法。这个方法可以接受一个包含实体对象的 Iterable（如 List）参数，并在单个事务中批量插入这些实体。

以下是一个示例代码：

首先，定义一个实体类 User：

```java
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String email;

    // Getters and setters
}
```
然后，创建一个继承自 JpaRepository 的接口 UserRepository，并使用 saveAll() 方法进行批量插入：

```java
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {
}
```
在上述示例中，我们没有在 UserRepository 接口中声明任何方法，因为我们只关注批量插入操作，而不需要其他查询功能。

接下来，在需要进行批量插入的地方，可以注入 UserRepository 并调用 saveAll() 方法来实现批量插入：

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {
    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public void saveUsers(List<User> users) {
        userRepository.saveAll(users);
    }
}
```
在上述示例中，我们创建了一个 UserService，通过构造函数注入了 UserRepository。然后，我们定义了一个 saveUsers() 方法，接受一个包含用户对象的列表，并调用 userRepository.saveAll() 方法来批量插入这些用户。

通过调用 saveUsers() 方法，您可以将多个用户对象作为参数传递给 saveAll() 方法，从而实现批量插入。

请注意，在调用 saveAll() 方法时，会在一个事务中执行批量插入操作，因此如果其中一个实体插入失败，整个批量插入操作将会回滚。

这样，您就可以使用 Spring Data JPA 实现简单而高效的批量插入操作。

## 不生效的场景

* 主键生成方式是`IDENTITY`
    * [https://docs.jboss.org/hibernate/orm/5.4/userguide/html_single/Hibernate_User_Guide.html#identifiers-generators-identity](https://docs.jboss.org/hibernate/orm/5.4/userguide/html_single/Hibernate_User_Guide.html#identifiers-generators-identity)
    * [https://stackoverflow.com/questions/63422129/is-hibernate-batching-with-identity-generation-possible](https://stackoverflow.com/questions/63422129/is-hibernate-batching-with-identity-generation-possible)

解决方案
* 参考链接修改主键生成方式
* 使用 `mybatis`或者`JDBC`插入