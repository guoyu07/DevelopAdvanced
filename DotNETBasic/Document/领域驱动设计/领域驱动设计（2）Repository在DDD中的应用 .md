##����


##EF��Repository


##Unit Of Work �� Repository

��������EfRepository��ʵ���У�ÿһ��Insert/Update/Delete������ִ��֮�󣬱���ͻ�����ͬ�������ݿ���ȥ��
��һ������û��Ϊ����������һ��������������ڶ������Ϊ���Ǵ��������ϵ���ʧ����Unit Of Workģʽ���ý�������ǵ����⣬������Martin Fowler ���ڸ�ģʽ�Ľ��ͣ�


*��A Unit of Work keep track of everything you do during a business transaction that can affect the database. When you��re done, it figures out everything that need to be done to alter the database as a result of your work.��

Unit of Work�����������ҵ��������������ݿ�ı�������������֮�����ҳ���Ҫ����ı�������������ݿ⡣*


��EF�У�DBContext��������Ѿ���һ��Unit Of Work��ģʽ

``` C#
namespace RepositoryAndEf.Core.Data
{
    public interface IUnitOfWork : IDisposable
    {
        int SaveChanges();
    }
}
```

##��мܹ�(The Onion Architecture)��IRepository

��мܹ�������У�ֻ����08���ʱ��[Jeffery](http://jeffreypalermo.com/blog/the-onion-architecture-part-1/)����ȡ�˸����֣�������Ϊ��һ��ģʽ��

����������ϵ��ǿ
![](http://images.cnitblog.com/blog/554526/201410/011354262222248.png)


����һ�ж�����BLLΪ���ģ�BLLҲ����Ҫ�������κ��������ˣ���Ϊ������һ�飬���ǿ��Ը����׵Ľ��е�Ԫ���ԣ��ع��ȡ�
![](http://images.cnitblog.com/blog/554526/201410/011426200348027.png)

*��ͳ���ܹ����ִ�����мܹ������ܹ�������*
![](http://images.cnitblog.com/blog/554526/201410/011450428003845.png)


##���¶���IRepository 

���ڣ������ٻع�ͷȥ��Repository����������ְ��

1. ������ʵ����������ڽ��й��������ݿ��ؽ����Լ��־û������ݿ⣩  �������Ƴٵ���Ӧ�ò�
2. ��������Ի�����ʩ������ 


##���п��޵�Repository

���ǰ�IRepository�Ƴ������֮���ټ������Ƕ���мܹ�����⡣���ǾͿ���֪��Repository��Ӧ�ò��Ѿ����Ա��滻�ɱ�Ķ�����IDALҲ���԰�:)��
��Ȼ����Ҳ��Ὠ��ֱ����EF���ö�ã���ʵ�Ҳ���������ȥ�������ǵ��Ժ��EF�����Ŀ����ԡ�
�������Ǽ�����һ���ӿ���Ĳ��ᰭ������ʲô�¡�������˾����ڶ�ȡ���ݵ�ʱ���һ��Repository���м䣬�ٵ��˺ܶ�EF�ṩ�Ĺ��ܣ����úܲ�ˬ�����ǿ������������ǵ�IQuery�ӿ�һ��ֱ�Ӷ�DbSet����ѯ��
������������ѧϰCQRS�ܹ������������ķ�����ȫ���뿪�����ǾͿ��Ե�����ԡ�������������ơ�

����Repository�����Ǵ������ŵ㣬��Щ�ŵ�Ҳ�����ǲ������׶�������ԭ��

1. �ṩһ���򵥵�ģ�ͣ�����ȡ�־ö��󲢹�������������
2. ��Ӧ�ú�������ƴӳ־ü������������ݿ���Խ������
3. ���ױ��滻����ʵ�֣�Mock)�Ա������ڲ�����ʹ��



[��̽����������ƣ�2��Repository��DDD�е�Ӧ��](http://www.cnblogs.com/jesse2013/p/ddd-repository.html)