#include<stdio.h>
#include<malloc.h>
#include<stdlib.h>
#include<stddef.h>

#define MAX 50
//�ڽӾ���ڵ����Ͷ���
typedef char vextype;
typedef struct {
   vextype vexs[MAX];
   int arcs[MAX][MAX];
   int vexnum;
   int arcnum;
}MGraph;
 MGraph *G;
//���е���������
typedef struct{
    int data[MAX];
    int front,rear;
  }queue;
   queue *q;
//�ڽӾ���ͼ
int LocateVex(MGraph *G,int v){
    int i=0;
    while(G->vexs[i]!=v){
        i++;
    }  
    return i;
}
void CreateUDN(MGraph *G){
    int i,j,k;

	printf("\n������ͼ�Ķ�����Ŀ:");
    scanf("%d",&G->vexnum);
    printf("\n������ͼ�ߵ���Ŀ:");
    scanf("%d",&G->arcnum);
	printf("\n������%d���������Ϣ:\n",G->vexnum);
	getchar();
	for(i=0;i<G->vexnum;i++){
		printf("\n�������%d���������Ϣ:",i+1);
		G->vexs[i]=getchar();
		getchar();		 
	}
	printf("\n��ӡȷ������Ķ����Ƿ�׼ȷ:\n");
	for(i=0;i<G->vexnum;i++){
		 printf("%2c   ",G->vexs[i]);
	}
	printf("\n\n");
	for(i=0;i<G->vexnum;i++){
		for(j=0;j<G->vexnum;j++)
			G->arcs[i][j]=0;
	}
	for(k=0;k<G->arcnum;k++){
		printf("�������%d����������,��:",k+1);
		scanf("%d%d",&i,&j);
		printf("\n");
		G->arcs[i][j]=G->arcs[j][i]=1;	
	}
}	

//�����ÿ�
void setnull(queue *q){
    q->front=q->rear=-1;
}
//�ж��п�
int empty(queue *q){
    if(q->front==q->rear){
		return 1;
    }
    else
		return 0;
}
//��Ӳ���
void enqueue(queue *q,int x){
    if(q->rear<G->vexnum-2){
        q->rear++;
        q->data[q->rear]=x;
      }
}
//���Ӳ���
int dequeue(queue *q){
	
    if(!empty(q)){
		q->front++;
		return 	q->data[q->front];	    
    }
	else 
	   return 0;
}

//BFS������ȱ���ͼ

int visited[MAX]; 
void BFS(MGraph *G,int k){
    int i=0 ,j; 
   
    setnull(q);
	visited[k]=1;
    enqueue(q,k);
    while(!empty(q)){
		i=dequeue(q);
		for(j=0;j<G->vexnum-1;j++){
			if(G->arcs[i][j]==1&&visited[j]!=0){
				printf("(%c,%c)",G->vexs[i],G->vexs[j]);
				visited[j]=1;
				enqueue(q,j);
			}
		}
	}
}

 
//DFS������ȱ���ͼ
void DFS(MGraph *G,int i){
	int j=0;
    visited[i]=1;
    for(j=0;j<G->vexnum;j++){
		if(G->arcs[i][j]==1&&visited[j]==0){
			printf("(%c,%c)",G->vexs[i],G->vexs[j]);
			DFS(G,j);
		}
    }

}
//**********************************  main   ����*****************
void main(){
	G=(MGraph *)malloc(sizeof(MGraph));
	q=(queue *)malloc(sizeof(queue));
	printf("******************************************************\n");
	printf("************�밴��ʾ����Ҫ������������ͨͼ************\n");
	printf("******************************************************\n");
	CreateUDN(G);
	printf("\n������ͨͼ������ȱ�����������ÿһ����Ϊ:\n");
	printf("******************************************************\n");
	DFS(G,0);
	printf("\n");
	printf("******************************************************\n");	
	printf("\n������ͨͼ������ȱ�����������ÿһ����Ϊ:\n");
	printf("******************************************************\n");
	BFS(G,0);
	printf("\n");
	printf("******************************************************\n");

}
    