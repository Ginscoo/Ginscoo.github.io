# Non-atomic Treatment of double and long
* double 和 long 不一定是原子性的，不同的JVM实现不同（官方推荐64位虚拟机原子实现）
* 有的虚拟机可能会将其拆分两个高低32位实现
* 多线程下，可能出现一个线程读取一半，另一个线程刚好进行修改，导致读取另一半不正确
* 保证不必要麻烦, 关键字 `volatile` 修饰则其一定为原子实现

# CAS （Compare And Swap）- 比较和交换
* 在多线程下，数字的自增可能是非原子的（可能在自增时，值被其他线程修改）
* Java中可用关键字`sychronized`， 单效果比较低，一般通过`Atomic*` 类实现，如 `AtomicInteger` or `AtomicLong`
* `Atomic*`，底层即为CAS实现

## AtomicInteger.incrementAndGet()
```
    /**
     * Atomically increments by one the current value.
     *
     * @return the updated value
     */
    public final int incrementAndGet() {
        return unsafe.getAndAddInt(this, valueOffset, 1) + 1;
    }

// Unsafe 方法
    public final int getAndAddInt(Object var1, long var2, int var4) {
        int var5;
        do {
            var5 = this.getIntVolatile(var1, var2);
        } while(!this.compareAndSwapInt(var1, var2, var5, var5 + var4));

        return var5;
    }

// 调用native方法

    public final native boolean compareAndSwapInt(Object var1, long var2, int var4, int var5);

```

# Lock
## 同步关键字 - sychronized 
* 可同步类或者代码块
* JVM自动实现，不用考虑锁的释放问题
* 阻塞的

## Lock 及其实现 ReentrantLock