#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#define M 18
void print1(int *a,int n){
    int *b;
    for(b=a;b<=a+n-1;b++){
        if( (b-a)%M==0 )printf("\n");
        printf("%2d",*b);
    }
    printf("\n\n");
}
void print2(int a[][M]){
    int i,j;
    for(i=1;i<17;i++){
        for(j=1;j<17;j++){
            if(a[i][j]==-1)
                printf(" *");
            else if(a[i][j]==0)
                printf(" .");
            else
                printf("%2d",a[i][j]);
        }
       printf("\n");
    }
}
void init(int a[][M]){//��ά�������βΣ�һ�е�Ԫ�ظ�����������֪�ġ������Ļ�����ά������ڴ涯̬����Ҳͦ�鷳�ġ�
    int i,j;
    int n; int mun; int m=0;
    int b[M][M];//����һ����ʱ���飬�����洢�������Χ����Ŀ�ġ�
//�����ʱ����a��һ���Ķ���18������16�������Ǹ������ǣ�Ϊ��ͳ�Ƽ����׹�ʽ��
    for(i=0;i<M;i++){
        for(j=0;j<M;j++)
            a[i][j]=b[i][j]=0;
    }
    mun=40;
    srand((int)time(0));
    while(m!=40){//����������ܲ�������ͬ�ģ�i,j��������֤����40���ס�
        mun=40-m; m=0;
        for(n=0;n<mun;n++){
            i=1+rand()%16; j=1+rand()%16; a[i][j]=-1;
        }
        for(i=0;i<M;i++)
            for(j=0;j<M;j++)
                if(a[i][j]==-1)m++;
    }
    for(i=1;i<M-1;i++){
        for(j=1;j<M-1;j++)
            b[i][j]=abs(a[i-1][j-1]+a[i-1][j]+a[i-1][j+1]+a[i][j-1]+a[i][j+1]+a[i+1][j-1]+a[i+1][j]+a[i+1][j+1]);
    }
    for(i=0;i<M;i++)
        for(j=0;j<M;j++){
            if(!a[i][j])
                a[i][j]+=b[i][j];
        }
    
}

void main(){
    int a[M][M];
    init(a);
	print2(a);
}