#include<stdio.h>
#include<string.h>
#include<time.h>
#define  MAX 30
#define  FM 21//�ı�FM��ֵ���Եõ�21λ�������еĻ�����

char Muns[10][FM+2]={"0","1","1","1","1","1","1","1","1","1"};  //��������洢0~9��21�ε��ַ�����
int N=0;
int Smun[10]; //�����洢 0~9��ɵ�21λ��ÿ�������������������Ա����ظ��������˵ 153��ˮ�ɻ�����
//Ȼ��135�϶��Ͳ���ˮ�ɻ� �������Ż������һ��ԭ����֪�����б�ĺ÷�����
int M=FM;

void multi(char *,char *,char *); //�������˷�
void add(char *,char *,char *);   //�������ӷ�
void init();                      //�洢0~9��21�η��ĺ�����
void flower(int,int);                 //����һ��ʹ�û����㷨�ĵݹ麯��������������������Ϊ��һ����������ġ�
void judge();                     //�����ж�һ��Smun����������������ˮ�ɻ���

void main(){
	int start = clock();
	int end;
	int j;

	init();
	memset(Smun,0,sizeof(Smun));//�������������е�Smun����ĳ�Ա�����0�Ŀ⺯��
	for(j=2;j<=21;j++){
	flower(0,j ); 
	end=clock();
	printf("%-3d%-10d%-10d����\n",j,N,end-start);
	start=end;
	N=0;
	}

}
void flower(int m,int j){
	int i;
	if(M==0) {
		N++;judge(); 
		return;
	}
	if(M<0) return;
	if(m==10) return;   //��0�ĸ������ǣ�һֱ��9��
	for(i=0;i<=j;i++){
	    M-=i;  Smun[m]=i;
		flower(m+1,j);
		Smun[m]=0; M+=i;
	}
}//�������һֱ�ڿ��Ļ����㷨

void judge(){
	int i;
	int amun[10];
	char b[10][FM+2];
	char Mun[FM+2]="0"; 
	for(i=0;i<=9;i++){
		if(Smun[i]<10){
			b[i][0]=Smun[i]+'0'; b[i][1]='\0';
		}
		else{
			b[i][0]=Smun[i]/10+'0'; b[i][1]=Smun[i]%10+'0'; b[i][2]='\0';}
	}
	for(i=0;i<=9;i++){
		multi(b[i],Muns[i],b[i]);
		add(Mun,b[i],Mun);
	}
	if(strlen(Mun)!=FM) return;
    memset(amun,0,sizeof(amun));
	for(i=0;i<FM;i++){
		amun[Mun[i]-'0']++;
	}
	for(i=0;i<10;i++){
		if(amun[i]!=Smun[i])  return;
	}
//	printf("%s\n",Mun);

}

void init(){
	int i;
	int j;
	char a[10][2]={"0","1","2","3","4","5","6","7","8","9"};
	for(i=2;i<=9;i++){
		for(j=0;j<FM;j++)
			multi(Muns[i],a[i],Muns[i]);
	}
}

void multi(char *num1,char *num2,char *muresult){
	int shu1[MAX+10];
	int shu2[MAX+10];
	int result[2*MAX+10];
	int i,j;
	int bstart=0;
	int len1, len2;
	int k;
	
	memset(shu1,0,sizeof(shu1));
	memset(shu2,0,sizeof(shu2));
	memset(result,0,sizeof(result));
	j=0; 
	len1=strlen(num1);
	for(i=len1-1;i>=0;i--)
		shu1[j++]=num1[i]-'0';
	j=0;
	len2=strlen(num2);
	for(i=len2-1;i>=0;i--)
		shu2[j++]=num2[i]-'0';

	for(i=0;i<len1;i++){
		for(j=0;j<len2;j++)
			result[i+j]+=shu1[i]*shu2[j];
	}

	for(i=0;i<2*MAX;i++){
		if(result[i]>=10){
			result[i+1]+=result[i]/10;
			result[i]%=10;
		}
	}
	k=1;
	for(i=2*MAX;i>=0;i--){
		if(bstart){
			muresult[k]=result[i]+'0';
			k++;
		}
		else if(result[i]){
			muresult[0]=result[i]+'0';
			bstart=1;
		}
	}
	muresult[k]='\0';
	if(!bstart){
		muresult[0]='0';
	    muresult[1]='\0';
	}

}

void add(char *num1,char *num2,char *adresult){
	int shu1[MAX+10];
	int shu2[MAX+10];
	int i,j;
	int bstart=0;
	int k;
	memset(shu1,0,sizeof(shu1));
	memset(shu2,0,sizeof(shu2));

    j=0;
	for(i=strlen(num1)-1;i>=0;i--)
		shu1[j++]=num1[i]-'0';

    j=0;
	for(i=strlen(num2)-1;i>=0;i--)
		shu2[j++]=num2[i]-'0';

	for(i=0;i<MAX+1;i++){
		shu1[i]+=shu2[i];
		if(shu1[i]>=10){
			shu1[i]-=10;
			shu1[i+1]++;
		}
	}
	k=1;
	for(i=MAX+1;i>=0;i--){
		if(bstart){
			adresult[k]=shu1[i]+'0';
			k++;
		}
		else if(shu1[i]){
			adresult[0]=shu1[i]+'0';
			bstart=1;
		}
	}
	adresult[k]='\0';
}
