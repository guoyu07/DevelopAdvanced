至此已经可以解释很多东西了。

1. 为什么要反向遍历？

    因为每个OwinMiddleware的构造函数的第一个参数或者Func<AppFunc,AppFunc>的参数都是一个next，指向下一个要运行的组件，那么这个next不应该为空，而且要真实有效，反向遍历会先生成后面OwinMiddleware或者Func，然后用其作为前一个的参数，这能保证构造的pipeline的有效性。

2. OwinMiddleware或者Func是如何串起来的？

    如上所述，每个OwinMiddleware或者Func的第一个参数都是一个next，OwinMiddleware或Func的方法都会调用其Invoke方法，不同的是OwinMiddleware的Invoke是一个可以重写的方法，参数为OwinContext，而Func是Delegate，其Invoke方法等同执行这个Func，参数为Envrionment。在Invoke中做了自己的工作之后，执行next.Invoke方法，并返回其结果，这样就串起来了。

3. PipelineStage是如何切换的？

    这将是下一节所要涉及的内容，每个PipelineStage都记录了NextStage，Pipeline调度部分可以在所有异步处理完成之后启用NextStage，这主要是未开源的System.Web.Application来完成调度的，采用了事件的机制。

总结，每个PipelineStage有个EntryPoint和ExitPoint，他们以及他们之前的其他OwinMiddleware或者Func通过next串联起来，执行的时候，由HttpApplication触发相应的事件。
pipeline能流动的关键因素是每个组件对于下一组件都有合法有效引用，所以采用反向遍历的方法来重建，Func调用下一Func为next.Invoke(environment)，OwinMiddleware调用下一OwinMiddleware为Next.Invoke(context)，
所以conversion主要是OwinMiddleware或者Func看到的next都是跟自己一个类型的。OwinMiddleware为了与Func一致，都采用了Invoke作为入口。



[AppBuilder（四）SignatureConversions ](http://www.cnblogs.com/hmxb/p/5303940.html)