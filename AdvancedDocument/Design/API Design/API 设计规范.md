﻿
1. 封装类的API,最好不要限制更底层的功能。如果因为功能不满足，需要用底层重写，这种API很垃圾，不要用这种API。

1. 业务方法里面遇到业务问题，例如参数错误。怎么返回给上一级，抛异常，返回错误代码。自定义异常！

## Web api

1. 新增的时候需要把新增对象返回，因为客户端需要这些数据，要不然只能去获取对象了。