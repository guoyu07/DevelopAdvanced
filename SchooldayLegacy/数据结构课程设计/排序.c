
#include "stdio.h"   
#include "stdlib.h"   
#include "string.h"   
#include "malloc.h"
#include "time.h"   
#define Max 100
#define Maxsize 1000

int n;
long com[7];
long exc[7];


//1 ѡ������

/*ֱ�Ӳ�������
���ڱ�
*/
void InsertSort(int a[]){
	int i,j,temp;
	for (i =1; i<n; i++) {
        temp = a[i]; 
		exc[0]++;
        for (j = i-1;j>-1&&a[j] >temp ; j--) {
			a[j+1] = a[j]; 
			a[j] = temp;
			com[0]++;
			exc[0]=exc[0]+2;
		}
	}
	
	for(i=0;i<n;i++){
		printf("%d ",a[i]);
		if(i%18==0&&i!=0)
			printf( "\n");
	}
		printf( "\n");
}

/* ϣ������ */
void ShellSort(int a[]){
     int gap,i,j,temp;
	 //����
     for(gap=n/2;gap>0;gap /= 2) {
		  //�������е���������һ�飿��
          for(i=gap;i<n;i++) {
			   //����ȷʵ�ǲ������򣨽�һ��δ��������֣����뵽ǰ���Ѿ���������У�
               for(j=i-gap;(j >= 0) && (a[j] > a[j+gap]);j -= gap ){
                temp=a[j];
                a[j]=a[j+gap];
                a[j+gap]=temp;
				com[3]++;
				exc[3]++;
               }
          }
     }
	 for(i=0;i<n;i++){
		 printf("%d ",a[i]);
		 if(i%18==0&&i!=0)
			 printf( "\n");
	 }
	printf( "\n");
}


// 2 ѡ������

/*ֱ��ѡ������*/
void SelectSort(int a[]){
     int i,j,min,temp; 
     for(i=0;i<n;i++) {
          min=i; 
          for(j=i+1;j<n;j++) {
			   //���ﲻ��Ҫ�滻�ģ������滻�Ĵ���
               if(a[min]>a[j]) {
                temp=a[i]; 
                a[i]=a[j]; 
                a[j]=temp;
			
				 exc[1]++;
               }
			   com[1]++;
          }
    }
	 for(i=0;i<n;i++){
		 printf("%d ",a[i]);
		 if(i%18==0&&i!=0)
			printf( "\n");	
	 }
	 printf( "\n");

}



 /* ������ */
//�ѵ���  ��Сλ�ã���ʼ������С�ѣ�
void HeapAdjust(int data[],int s,int m){ 
     int j,rc; 
     rc=data[s];    
     for(j=2*s;j<=m;j*=2) {     
	     //���ҽڵ�ȡ��� �ҵ��Ǵ������
		 if(j<m && data[j]<data[j+1]) {
			  com[4]++;
			  j++;
		 }
          if(rc>data[j]) 
			  break; 
          data[s]=data[j];  
          s=j; 
		  exc[4]++;
		 }
    data[s]=rc;     
}

void HeapSort(int a[]){
     int i,temp;
	//������
	//��n/2������ʼ���е�����
     for(i=n/2;i>0;i--)  
     {
      HeapAdjust(a,i,n);
	 }
     
     for(i=n;i>1;i--){
      temp=a[1];    
      a[1]=a[i]; 
      a[i]=temp;   
      HeapAdjust(a,1,i-1);
     }
	 
	 for(i=1;i<=n;i++){
		  printf("%d ",a[i]);
		  if(i%18==0&&i!=0)
			printf( "\n");
	 }
	 printf( "\n");
}

//3 ��������
/* ð������ */

void BubbleSort(int a[]){
	int i,j,k;
    for(j=0;j<n;j++){
          for(i=0;i<n-j-1;i++){
               if(a[i]>a[i+1]){
                    k=a[i];
                    a[i]=a[i+1];
                    a[i+1]=k;
					exc[2]++;
               }
			   com[2]++;
          }
     }

	for(i=0;i<n;i++){
		printf("%d ",a[i]);
		if(i%18==0&&i!=0)
			printf( "\n");

	 }
	printf( "\n");
}

/*˫��ð������ */
//void dBubbleSort (int a[]){
//	int flag=-1;
//	int i,j;
//	int k;
//	for(j=1;j<n;j++){
//		flag=flag*-1;
//		if(flag==1){
//			for(i=j/2;i<=n-2-j/2;i++){
//					if(a[i]>a[i+1]){
//                    k=a[i];
//                    a[i]=a[i+1];
//                    a[i+1]=k;
//					exc[7]=exc[7]+3;
//					}
//				com[7]++;
//			}
//		}
//	 else{
//		 for(i=n-1-j/2;i>=j/2;i--)  {
//			 if(a[i]<a[i-1]){
//				 k=a[i-1];
//				 a[i-1]=a[i];
//				 a[i]=k;
//				 exc[7]=exc[7]+3;
//			 }
//			 com[7]++;
//		 }
//	 }
//	}
//	for(i=0;i<n;i++){
//		printf("%d ",a[i]);
//		if(i%18==0&&i!=0)
//		printf( "\n");
//	}
//	printf( "\n");
//}




/*��������*/



int Partition(int data[],int low,int high){
	int mid;
	
	//���岻���Ĵ��룡
	data[0]=data[low];
	
	//ȡ��׼��  �����Ż���
	mid=data[low];
	while(low < high){
		while((low < high) && (data[high] >= mid)){
	        com[5]++;
			--high;
		}
		//����ұ�С�ڻ�׼���򽻻�
		data[low]=data[high]; 
		exc[5]++;
		while((low < high) && (data[low] < mid)){
			com[5]++;
			++low;
		}
		
		//�����ߴ��ڻ�׼���򽻻�
		data[high]=data[low];
	}
	data[low]=data[0];   
	
	//�·���߽�������
	return low;    
}


void Quick(int data[],int low,int high){
	int mid;
	if(low<high){
		mid=Partition(data,low,high);
		Quick(data,low,mid-1); 
		Quick(data,mid+1,high);
	}
}

void QuickSort(int b[]){
	int i;
	Quick(b,1,n); 
	for(i=1;i<=n;i++){
		printf("%d ",b[i]);
		if(i%18==0&&i!=0)
			printf( "\n");
	}
	printf( "\n");
}


//4 �鲢����

/*�鲢����*/



void Merge(int sr[],int tr[],int i,int m,int l){
	int s;
	int r;
	int j;
	int k;
	//m �м����� iС��λ��l����λ��

	// //���ȿ�������ν��������������кϲ�������ǳ��򵥣�ֻҪ�ӱȽ϶������еĵ�һ������˭С����ȡ˭��ȡ�˺���ڶ�Ӧ������ɾ���������Ȼ���ٽ��бȽϣ����������Ϊ�գ���ֱ/////�ӽ���һ�����е���������ȡ�����ɡ�
	for(j=m+1,k=i;i<=m&&j<=l;++k){
		if(sr[i]<sr[j]){
			tr[k]=sr[i];
			i++;
		}
		else {
			tr[k]=sr[j];
			j++;
		
		}
		com[6]++;
		exc[6]++;
	}
	if(i<=m){
		for(s=k,r=i;s<=l&&r<=m;r++){
	        tr[s]=sr[r];
		    s++;
		    exc[6]++;
		}
	   
	}
	if(j<=l){
		for(s=k,r=j;s<=l&&j<=l;r++){
	        tr[s]=sr[r];
		    s++;
		    exc[6]++;
	   }
	}
}



void MSort(int sr[],int tr1[] ,int s,int t){
	
	int m=0;
	int tr2[Max]={0};

	if(s==t)
		tr1[s]=sr[s];
	else{
		//ȥ�м�����
		m=(s+t)/2;
	    MSort(sr,tr2,s,m);
		MSort(sr,tr2,m+1,t);
		Merge(tr2,tr1,s,m,t);
	}
}

void MergeSort(int a[]){
	int b[Max]={0};
	int i;
	MSort(a,b,1,n);
		 for(i=1;i<=n;i++){
		     printf("%d ",b[i]);
			 if(i%18==0&&i!=0)
			     printf( "\n");
		 }
		 printf( "\n");
}

//20150410 ��ϰ��һ�£�����������
void Sort(int a[]){
	int b[Max];
	int i;
	for( i=0; i<n;i++)
		b[i]=a[i];
	printf("ֱ�Ӳ���������Ϊ��\n");
	InsertSort(b);
	
	for( i=0; i<n;i++)
		b[i]=a[i];
	printf("ֱ��ѡ��������Ϊ��\n");
	SelectSort(b);

	for( i=0; i<n;i++)
		b[i]=a[i];
			 
	printf("ð��������Ϊ��\n");
	BubbleSort(b);

	for( i=0; i<n;i++)
	b[i]=a[i];

	printf("˫��ð��������Ϊ��\n");
	//dBubbleSort(b);

	for( i=0; i<n;i++)
		b[i]=a[i];
	printf("ϣ��������Ϊ:\n");
	ShellSort(b);  
	
	for( i=0; i<n;i++)
	    b[i+1]=a[i];
	printf("��������Ϊ\n");
	HeapSort(b);
		     
	for( i=0; i<n;i++)
		b[i+1]=a[i];
	printf("����������Ϊ:\n");
	QuickSort(b);
	
	for( i=0; i<n;i++)
		b[i+1]=a[i];
	printf("�鲢������Ϊ:\n");
	MergeSort(b);
	
	printf("\n������Ŀ:%d\n",n);
	printf(  "ֱ�Ӳ�������: �Ƚϴ���Ϊ:%5ld �ƶ�����Ϊ:%6ld ������������Ϊ��%ld\n",com[0],exc[0],com[0]+exc[0]);
	printf(  "ֱ��ѡ������: �Ƚϴ���Ϊ:%5ld �ƶ�����Ϊ:%6ld ������������Ϊ��%ld\n",com[1],3*exc[1],com[1]+3*exc[1]);
	printf(  "ð������:     �Ƚϴ���Ϊ:%5ld �ƶ�����Ϊ:%6ld ������������Ϊ��%ld\n",com[2],3*exc[2],com[2]+3*exc[2]);
	//printf(  "˫��ð������: �Ƚϴ���Ϊ:%5ld �ƶ�����Ϊ:%6ld ������������Ϊ��%ld\n",com[7],exc[7],com[7]+exc[7]);
	printf(  "ϣ������:     �Ƚϴ���Ϊ:%5ld �ƶ�����Ϊ:%6ld ������������Ϊ��%ld\n",com[3],3*exc[3],com[3]+3*exc[3]);
	printf(  "������:       �Ƚϴ���Ϊ:%5ld �ƶ�����Ϊ:%6ld ������������Ϊ��%ld\n",com[4],exc[4],com[4]+exc[4]);
	printf(  "��������:     �Ƚϴ���Ϊ:%5ld �ƶ�����Ϊ:%6ld ������������Ϊ��%ld\n",com[5],2*exc[5],com[5]+2*exc[5]);
	printf(  "�鲢����:     �Ƚϴ���Ϊ:%5ld �ƶ�����Ϊ:%6ld ������������Ϊ��%ld\n",com[6],exc[6],com[6]+exc[6]);
	for(i=0;i<=7;i++){
		com[i]=0;
		exc[i]=0;
			
	}
			  
}




void main(){ 
	int a[Max];
   
	int m;
	int i,j,k;
	    
    printf("������������Ŀ(<100)��ĿΪ0�˳�����\n");
	scanf_s("%d",&n);

	while(n!=0){
		printf("��ѡ�������������:1:���� 2:���� 3:��� �����򷵻���һ��(4:����)\n");
		scanf_s("%d",&m);
	
		switch(m){
		case 1:
			printf("\n����ǰ��������Ϊ��\n");
			srand( (unsigned)time( NULL ) );     
			 for( i= 0; i <n;i++ ){
				 a[i]=rand()%Maxsize;
				
			 }

			 for(j=0;j<n;j++){
				 for(i=0;i<n-j-1;i++)  
				 {
					if(a[i]>a[i+1]){
                     k=a[i];
                    a[i]=a[i+1];
                    a[i+1]=k;
					 }
				 }
			 }
			 
			 for( i=0; i <n;i++ ){
			     printf( "%d ",a[i]);
				 if(i%19==0&&i!=0)
			         printf( "\n");
			 }
			 printf( "\n");
			 Sort(a);

			 break;
         case  2:
			 printf("\n����ǰ��������Ϊ��\n");
			 srand( (unsigned)time( NULL ) );     
			  for( i=0; i<n;i++ ){
				 a[i]=rand()%Maxsize;
				
			 }
			 for(j=0;j<n;j++){
				 for(i=0;i<n-j-1;i++)  
				 {
					 if(a[i]<a[i+1]){
                     k=a[i];
                     a[i]=a[i+1];
                     a[i+1]=k;
					 }
				 }
			 }
			 for( i=0; i <n;i++ ){
			      printf( "%d ",a[i]);
				  if(i%19==0&&i!=0)
			          printf( "\n");
			 }
			 printf( "\n");
			 Sort(a);
		     break;
         case  3:
			 printf("\n����ǰ���������Ϊ��\n");
			 srand( (unsigned)time( NULL ) );     
			 for( i= 0; i <n;i++ ){
				 a[i]=rand()%Maxsize;
				 printf( "%d ",a[i]);
				 if(i%19==0&&i!=0)
			         printf( "\n");
				 
			 }
			 printf( "\n");
             Sort(a);
			 break;
		  case 4:
			  system("cls");
			  printf("������Ŀ:%d\n",n);
			
        default:
			 break;
		}

		if(m<1||m>4){
			printf("������������Ŀ,��ĿΪ0�˳�����\n");
			scanf_s("%d",&n);
		}
	}
}



