#include "stdlib.h"
#include "stdio.h"
#include "malloc.h"
#define null 0
#include "stdio.h"   
#define Max 100


struct List
{
	int data;
	struct List *next;
}List;

int  m=1;
int n;


struct List * InitList(int a[])
{
	struct List *head,*p,*q;
	int i;
	head=(struct List *)malloc(sizeof(struct List));
	head->next=null; 
	q=head;
	for(i=0;i<n;i++){
	   p=(struct List *)malloc(sizeof(struct List));
	   p->next=null;
	   p->data=a[i];
	   q->next=p;
	   q=p;
	   }
	return head;
}

void print(struct List *head)
{//�����ǰ����
	struct List *p;
	if(head)
	{
	   p=head->next; 
	   while(p) 
	   {
		printf("%4d ",p->data);
		p=p->next;
	   }
	   printf("\n");
	}
}

void SelectSort (struct List *head)
{//��ѡ�񷨽�������
	struct List *p,*q;
	int t;
	for(p=head->next;p->next;p=p->next){
		for(q=p->next;q;q=q->next)
		   if(p->data>q->data)
			{
				t=p->data;
				p->data=q->data;
				q->data=t;
			}

		  printf("��%d������������:\n",m);
			  print(head);

		  m++;
        }
	
}

void BubbleSort (int a[]){

	int flag=-1;
	int i,j;
	int k;

	
	for(j=1;j<n;j++){
	
	    flag=flag*-1;
		if(flag==1){
			for(i=j/2;i<=n-2-j/2;i++){
					if(a[i]>a[i+1]){
                    k=a[i];
                    a[i]=a[i+1];
                    a[i+1]=k;
					}
				}
				printf( "\n��%d������������Ϊ:\n",j);
		        for(i=0;i<n;i++){
					printf( "%4d ",a[i]);
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
				printf( "\n��%d������������Ϊ:\n",j);
				for(i=0;i<n;i++){
					printf( "%4d ",a[i]);
					if(i%18==0&&i!=0)
						printf( "\n");
				}
			}
			
		}
	}



void main(){
	struct List *head;
	int a[Max];

	int i;
	printf("������������Ŀ(<99)��ĿΪ0�˳�����\n");
	scanf("%d",&n);
	printf("������%d������\n",n);
	while(n!=0){
		for(i=0;i<n;i++){
			scanf("%d",&a[i]);
		}

	
		head=InitList(a);
		printf("ѡ�����������ÿ�˵������������洢��\n");
		SelectSort(head);

		printf("\n˫��ð�����������ÿ�˵������������洢)");
	
		BubbleSort(a);
		printf("\n������������Ŀ,��ĿΪ0�˳�����\n");
		scanf("%d",&n);
		printf("������%d������\n",n);
	}
}





