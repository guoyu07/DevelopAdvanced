#include<stdio.h>
#define MAX  20
#define REMUN  20000
int  Price[MAX];       //ÿһ����Ʒ�ļ۸�
int  Mun[REMUN][MAX];//��¼���ս����
int  Mmun[MAX];      //����洢����ÿһ����Ʒ���ܵ������Ŀ�����ٲ���Ҫ��ѭ��
int  Cmun[MAX];      //������ǰ������Ʒ����Ŀ
int  N=0;                 //�����
int  M;                     //��Ʒ����
int  Money=1000;

void buy(int m){
    int i,k;
    if(Money<0) return ;
    if(Money==0){
        for(k=0;k<M;k++)
           Mun[N][k]=Cmun[k];
        N++; return ;
    }
    if(m==M)  return;
    for(i=0;i<Mmun[m];i++){
        Money-=i*Price[m]; Cmun[m]=i;
        buy(m+1);
     /*
      �����⼸������������֧״̬�ģ�Ȼ������ķ�֧״̬��
      ���������������⣬�����㷨����һ���ܺõĽ��������
      2��������䣬����Щ�ظ���ԭ���������ֻ�� i ��ֵ�ı��ˣ�
      ���ݲ����ʼֻ�����һ����䣬Ȼ����һ��һ�����Բų�����������䣬��ĺ����棡
     */
      Cmun[m]=0; Money+=i*Price[m];
    }
}

void main(){
    int i,j;
    scanf("%d",&M);
    for(i=0;i<M;i++){
        scanf("%d",&Price[i]);
    }
    for(i=0;i<M;i++){
        Mmun[i]=Money/Price[i]+1;
    }
    buy(0);
    printf("%d\n",N);
	
    for(i=0;i<N;i++){
        for(j=0;j<M;j++)
            printf("%-3d",Mun[i][j]);
        printf("\n");
    }

}