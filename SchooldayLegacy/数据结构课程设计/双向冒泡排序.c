#include "stdio.h"   
#include "stdlib.h"
#include "time.h"   
#define Max 100
#define Maxsize 1000 

void main(){
	int a[Max];
	int flag=-1;
	int n;
	int i,j;
	int k;
	int m=0;

	printf("������������Ŀ(<99)��ĿΪ0�˳�����\n");
	scanf("%d",&n);
	while(n!=0){
		printf("\n����ǰ��������Ϊ��\n");
		srand( (unsigned)time( NULL ) );     
			 for( i= 0; i <n;i++ ){
				 a[i]=rand()%Maxsize;
				 printf( "%d ",a[i]);
				 if(i%18==0&&i!=0)
			         printf( "\n");
				 }
	
       
		for(j=1;j<=n;j++){
		     m++;

			flag=flag*-1;
			if(flag==1){
				for(i=j/2;i<=n-2-j/2;i++){
					if(a[i]>a[i+1]){
                    k=a[i];
                    a[i]=a[i+1];
                    a[i+1]=k;
					}
				}
				printf( "\n��%d������������Ϊ:\n",m);
		        for(i=0;i<n;i++){
					printf( "%d ",a[i]);
					if(i%18==0&&i!=0)
						printf( "\n");
				}
			}
			else{
				for(i=n-1-j/2;i>=j/2;i--)  {
					if(a[i]<a[i-1]){
						k=a[i-1];
						a[i-1]=a[i];
						a[i]=k;
					}
				}
				printf( "\n��%d������������Ϊ:\n",m);
				for(i=0;i<n;i++){
					printf( "%d ",a[i]);
					if(i%18==0&&i!=0)
						printf( "\n");
				}
			}
			
		}
	
			
		printf( "\n");
		printf("������������Ŀ,��ĿΪ0�˳�����\n");
		scanf("%d",&n);
}
}

