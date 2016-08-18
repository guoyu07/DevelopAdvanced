##�첽��̣������¼����첽���ģʽ(EAP)

.NET2.0 �������ˣ������¼����첽���ģʽ(EAP��Event-based Asynchronous Pattern)��ͨ���¼���AsyncOperationManager���AsyncOperation��������������ʵ�����¹��ܣ�

1)   �첽ִ�к�ʱ������

2)   ��ý��ȱ�������������

3)   ֧�ֺ�ʱ�����ȡ����

4)   �������Ľ��ֵ���쳣��Ϣ��

5)   �����ӣ�֧��ͬʱִ�ж���첽���������ȱ��桢���������ȡ�����������ؽ��ֵ���쳣��Ϣ��

������Լ򵥵Ķ��߳�Ӧ�ó���BackgroundWorker����ṩ��һ���򵥵Ľ�����������ڸ����ӵ��첽Ӧ�ó��򣬿��Կ���ʵ��һ�����ϻ����¼����첽ģʽ���ࡣ 


###EAP�첽���ģ�͵��ŵ�

EAP��ΪWindows���忪����Ա�����ģ�����Ҫ�ŵ����ڣ�

1.   EAP��Microsoft Visual Studio UI����������˺ܺõļ��ɡ�Ҳ����˵���ɽ������ʵ����EAP�����Ϸŵ�һ��Visual Studio�����ƽ���ϣ�Ȼ��˫���¼�������Visual Studio�Զ������¼��ص���������������ͬ�¼�����������

2.   EAP�����ڲ�ͨ��SynchronizationContext�࣬��Ӧ�ó���ģ��ӳ�䵽�����̴߳���ģ�ͣ��Է�����̲߳����ؼ���


###AsyncOperationManager��AsyncOperation

AsyncOperationManager���AsyncOperation���API���£�


``` C#
// Ϊ֧���첽�������õ����ṩ�����������಻�ܱ��̳С�

public static class AsyncOperationManager

{

    // ��ȡ�����������첽������ͬ�������ġ�

    public static SynchronizationContext SynchronizationContext { get; set; }

 

    // ���ؿ����ڶ��ض��첽�����ĳ���ʱ����и��ٵ�AsyncOperation����

    // ����:userSuppliedState:

    //     һ����������ʹһ���ͻ���״̬�������� ID����һ���ض��첽�����������

    public static AsyncOperation CreateOperation(object userSuppliedState)

    {

        return AsyncOperation.CreateOperation(userSuppliedState,SynchronizationContext);

    }

}

 

// �����첽�����������ڡ�

public sealed class AsyncOperation

{

    // ���캯��

    private AsyncOperation(object userSuppliedState, SynchronizationContext syncContext);

    internal static AsyncOperation CreateOperation(object userSuppliedState

                                            , SynchronizationContext syncContext);

 

    // ��ȡ���ݸ����캯����SynchronizationContext����

    public SynchronizationContext SynchronizationContext { get; }

    // ��ȡ����������Ψһ��ʶ�첽�����Ķ���

    public object UserSuppliedState { get; }

 

    // �ڸ���Ӧ�ó���ģ���ʺϵ��̻߳��������е���ί�С�

    public void Post(SendOrPostCallback d, object arg);

    // �����첽�����������ڡ�

    public void OperationCompleted();

    // Ч��ͬ���� Post() + OperationCompleted() �������

    public void PostOperationCompleted(SendOrPostCallback d, object arg);

}
```


    �ȷ������������������ࣺ

1.   AsyncOperationManager�Ǿ�̬�ࡣ��̬�����ܷ�ģ���˲��ɱ��̳С������Ӿ�̬��̳лᱨ����̬������ Object ����������С��ʶ����ǰ��Ϊ�ܷ������ sealed �ؼ��֣�

2.   AsyncOperationManagerΪ֧���첽�������õ����ṩ����������������������� .NET Framework ֧�ֵ�����Ӧ�ó���ģʽ�¡�

3.   AsyncOperationʵ���ṩ���ض��첽����������ڽ��и��١������������������֪ͨ�����������ڲ���ֹ�첽����������·������ȱ����������������ֲ���ֹ�첽�����Ĵ�����ͨ��AsyncOperation�� Post() ����ʵ�֣���

4.   AsyncOperation����һ��˽�еĹ��캯����һ���ڲ�CreateOperation() ��̬��������AsyncOperationManager�����AsyncOperation.CreateOperation() ��̬����������AsyncOperationʵ����

5.   AsyncOperation����ͨ��SynchronizationContext����ʵ���ڸ���Ӧ�ó�����ʵ����̻߳������ġ����ÿͻ����¼��������


    ```C#
    // �ṩ�ڸ���ͬ��ģ���д���ͬ�������ĵĻ������ܡ�

    public class SynchronizationContext

    {

        // ��ȡ��ǰ�̵߳�ͬ�������ġ�

        public static SynchronizationContext Current { get; }

 

        // ��������������дʱ����Ӧ�����ѿ�ʼ��֪ͨ��

        public virtual void OperationStarted();

        // ��������������дʱ�����첽��Ϣ���ȵ�һ��ͬ�������ġ�

        public virtual void Post(SendOrPostCallback d, object state);

        // ��������������дʱ����Ӧ��������ɵ�֪ͨ��

        public virtual void OperationCompleted();

        ����

    } 
    ```

    a)   ��AsyncOperation���캯���е���SynchronizationContext��OperationStarted() ��

    b)       ��AsyncOperation�� Post() �����е���SynchronizationContext��Post() ��

    c)   ��AsyncOperation��OperationCompleted()�����е���SynchronizationContext��OperationCompleted()��

6.   SendOrPostCallbackί��ǩ����

    // ��ʾ����Ϣ���������ȵ�ͬ��������ʱҪ���õķ�����

    public delegate void SendOrPostCallback(object state);


    

###�����¼����첽ģʽ������

1.   �����¼����첽ģʽ���Բ��ö�����ʽ������ȡ����ĳ���ض���֧�ֲ����ĸ��ӳ̶ȣ�

    1)   ��򵥵������ֻ��һ�� ***Async������һ����Ӧ�� ***Completed �¼����Լ���Щ������ͬ���汾��

    2)   ���ӵ�����������ɸ� ***Async������ÿ�ַ�������һ����Ӧ�� ***Completed �¼����Լ���Щ������ͬ���汾��

    3)   �����ӵ��໹����Ϊÿ���첽����֧��ȡ����CancelAsync()�����������ȱ�������������ReportProgress() ����+ProgressChanged�¼�����

    4)   ���������֧�ֶ���첽������ÿ���첽�������ز�ͬ���͵����ݣ���Ӧ�ã�

    a)   ����������������������Ľ��ȱ���ֿ���

    b)   ʹ���ʵ���EventArgsΪÿ���첽��������һ�������� ***ProgressChanged�¼��Դ���÷���������������ݡ�

    5)   ����಻֧�ֶ���������ã��뿼�ǹ���IsBusy���ԡ�

    6)   ��Ҫ�첽������ͬ���汾���� Out �� Ref ����������Ӧ��Ϊ��Ӧ ***CompletedEventArgs��һ���֣�



2.   ���������Ҫ֧�ֶ���첽��ʱ��������ִ�С���ô��

    1)   Ϊ***Async���������һ��userState����������˲���Ӧ��ʼ����***Async����ǩ���е����һ�������������ڸ��ٸ��������������ڡ�

    2)   ע��Ҫ���㹹�����첽����ά��һ��userState����ļ��ϡ�ʹ�� lock ���򱣻��˼��ϣ���Ϊ���ֵ��ö����ڴ˼�������Ӻ��Ƴ�userState����

    3)   ��***Async������ʼʱ����AsyncOperationManager.CreateOperation������userState����Ϊÿ���첽���񴴽�AsyncOperation����userState�洢��AsyncOperation��UserSuppliedState�����С��ڹ������첽����ʹ�ø����Ա�ʶȡ���Ĳ����������ݸ�CompletedEventArgs��ProgressChangedEventArgs������UserState��������ʶ��ǰ�������Ȼ�����¼����ض��첽����

    4)   ����Ӧ�ڴ�userState�����������������¼�ʱ���㹹�����첽��Ӧ��AsyncCompletedEventArgs.UserState����Ӽ�����ɾ����

3.   �쳣����

    EAP�Ĵ������ϵͳ�����ಿ�ֲ�һ�¡����ȣ��쳣�����׳���������¼��������У������ѯAsyncCompletedEventArgs��Exception���ԣ������ǲ���null���������null���ͱ���ʹ��if����ж�Exception������������ͣ�������ʹ��catch�顣 

    ���⣬�����Ĵ�����Դ�����ô���ᷢ��δ������쳣���������δ����⵽��Ӧ�ó��򽫼������У���������Ԥ֪�� 


###BackgroundWorker���

System.ComponentModel�����ռ��BackgroundWorker���Ϊ�����ṩ��һ���򵥵Ķ��߳�Ӧ�ý�����������������ڵ������߳������к�ʱ���������ᵼ���û���������������ǣ�Ҫע����ͬһʱ��ֻ������һ���첽��ʱ������ʹ��IsBusy�����ж��������Ҳ��ܿ�AppDomain�߽���з��ʹ��������ڶ��AppDomain��ִ�ж��̲߳�������


``` C#
public class BackgroundWorker : Component

{

    public BackgroundWorker();

 

    // ��ȡһ��ֵ��ָʾӦ�ó����Ƿ�������ȡ����̨������

    public bool CancellationPending { get; }

    // ��ȡһ��ֵ��ָʾBackgroundWorker�Ƿ����������첽������

    public bool IsBusy { get; }

    // ��ȡ������һ��ֵ����ֵָʾBackgroundWorker�ܷ񱨸���ȸ��¡�

    public bool WorkerReportsProgress { get; set; }

    // ��ȡ������һ��ֵ����ֵָʾBackgroundWorker�Ƿ�֧���첽ȡ����

    public bool WorkerSupportsCancellation { get; set; }

 

    // ����RunWorkerAsync() ʱ������

    public event DoWorkEventHandlerDoWork;

    // ����ReportProgress(System.Int32) ʱ������

    public event ProgressChangedEventHandlerProgressChanged;

    // ����̨��������ɡ���ȡ���������쳣ʱ������

    public event RunWorkerCompletedEventHandlerRunWorkerCompleted;

 

    // ����ȡ������ĺ�̨������

    public void CancelAsync();

    // ����ProgressChanged�¼���percentProgress:��Χ�� 0% �� 100%

    public void ReportProgress(int percentProgress);

    // userState:���ݵ�RunWorkerAsync(System.Object) ��״̬����

    public void ReportProgress(int percentProgress, object userState);

    // ��ʼִ�к�̨������

    public void RunWorkerAsync();

    // ��ʼִ�к�̨������argument:���ݸ�DoWork�¼���DoWorkEventArgs������

    public void RunWorkerAsync(object argument);

}
```

6)   ȷ����DoWork�¼���������в������κ��û�������󡣶�Ӧ��ͨ��ProgressChanged��RunWorkerCompleted�¼����û��������ͨ�š�

��ΪRunWorkerAsync() ��ͨ��ί�е�BeginInvoke() ������DoWork�¼�����DoWork�¼���ִ���߳��Ѳ��Ǵ����ؼ����̣߳����ڡ��첽��̣��첽���ģ�� (APM)���н����˼��ֿ��̷߳��ʿؼ��ķ�ʽ������ProgressChanged��RunWorkerCompleted�¼���ͨ����������AsyncOperation�� Post() ����ʹ����÷����ں��ʵġ��̻߳������ġ��С�


[�첽��̣������¼����첽���ģʽ(EAP)](http://www.cnblogs.com/heyuquan/archive/2013/04/01/2993085.html)