## IIS Host

֧��IIS pineline event��


## Self-Host

###ʹ��WebApi

``` C#
public void Configuration(IAppBuilder appBuilder) 
    { 
        // Configure Web API for self-host. 
        HttpConfiguration config = new HttpConfiguration(); 
        config.Routes.MapHttpRoute( 
            name: "DefaultApi", 
            routeTemplate: "api/{controller}/{id}", 
            defaults: new { id = RouteParameter.Optional } 
        ); 

        appBuilder.UseWebApi(config); 
    } 
```

[ʹ�� OWIN Self-Host ASP.NET Web API 2 ](http://www.cnblogs.com/shanyou/p/3650705.html)