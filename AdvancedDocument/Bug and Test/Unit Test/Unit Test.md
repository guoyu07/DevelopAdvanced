﻿##什么时候需要Unit Test

* 基础库所有接口都需要Unit Test

* 以后考虑怎样将Unit Test融入到项目里

##Unit Test的输入

* Unit Test最好有无穷随机的输入，这种考验后基本不会有Bug。基本算法和数据结构
这个很容易实现

##方法

* 写Unit Test最好每步关键操作都要做全面测试，例如插入操作，无法知道那一个插入出错是
不可能找到问题的

* 就算是Unit Test也需要Helper类

* 重写Tostring方法是Test的一个好手段

* 先直接Run Test，出问题再Debug

* 保证所有的输入在不改变方法执行的情况下执行结果是唯一的

* 对同一个方法通过的测试数据不要删除，而是统一的放到一个方法，例如Passed开头的方法

* 特定情况下为每一个Unit Test方法写一个方法，让它调用，Unit Test方法只包含多个输入。 

##感想

* Algorithm里这些Unit Test写的上瘾，因为没有大量测试根本没法保证我写的是对的，也没办法能够正确实现。
可能测试驱动开发就是这样子的。很多时候期待结果验证比较简单，但是实现难度比较大。

* 能写Unit Test的代码都是好代码







