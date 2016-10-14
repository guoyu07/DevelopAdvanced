#include "stdio.h"
#include "malloc.h"
#include "string.h"
#define  maxsize 12
#define  size 100

/*����ڵ�*/

typedef struct node{
	char phonenum[maxsize];
	char name[maxsize];
    struct node*next;
}phonelist;

struct node2{
	 char name[maxsize];
    char phonenum[maxsize];
 }phonearray[size];

phonelist *head;

phonelist *creatphonelist(){
	phonelist*p,*s,*head;
	head=malloc(sizeof(phonelist));
	head->next=NULL;
	printf("���������������ͺ�����#��������\n");
	while(1){
		s=malloc(sizeof(phonelist));
		scanf("%s",s->name);
		
		if(s->name[0]=='#')
			break;
		scanf("%s",s->phonenum);
		p=head;
		s->next=p->next;
		p->next=s;
	}
	return(head);
}

void output(phonelist *head){
	phonelist *p;
	p=head->next;
	while(p!=NULL){
		printf("%10s%15s\n",p->name,p->phonenum);
		p=p->next;
	}
	
}

void insert(phonelist *head){
	phonelist *p,*s;
	s=malloc(sizeof(phonelist));
	printf("���������������ͺ���\n");
	scanf("%s%s",s->name,s->phonenum);
	p=head;
	while(p->next!=NULL){
	    p=p->next;
	}
	s->next=p->next;
	p->next=s;
}

void delete(phonelist *head,char name[]){
	phonelist *p,*s;
	
	p=head;
	while(p->next!=NULL)
		if(strcmp(name,p->next->name)!=0)
	    p=p->next;
		else
		break;
		
		if(p->next!=NULL){
			s=p->next;
			p->next=s->next;
			printf("%s�Ѵ�ͨѶ¼��ɾ��\n",name);
		}
		else
			printf("%s������ͨѶ¼��\n",name);
}


phonelist *search(phonelist *head,char name[]){
	phonelist *p;
	p=head->next;
	while(p!=NULL&&strcmp(name,p->name)!=0)
		p=p->next;
	return p;
}


void save(phonelist *head){
	int i=0;
	FILE *out;
	phonelist *p;
	if((out=fopen("ͨѶ¼","wb"))==NULL){
			printf("�򲻿��ļ�\n");
			return;
	}

	p=head->next;
	while(p!=NULL){
		strcpy(phonearray[i].name,p->name);
		strcpy(phonearray[i].phonenum,p->phonenum);
		if(fwrite(&phonearray[i],sizeof(struct node2),1,out)!=1)
		    printf("д����Ϣʧ��\n");
		i++;
		p=p->next;
	}
	 strcpy(phonearray[i].name,"#");
	 if(fwrite(&phonearray[i],sizeof(struct node2),1,out)!=1)
		   printf("д����Ϣʧ��\n");
	 fclose(out);
}

void open(){
	int i;
	phonelist *p,*q,*s;

	FILE*open;
	if((open=fopen("ͨѶ¼","rb"))==NULL){
			printf("phonelist�ļ��������޷���ȡ");
			return;
	}
	p=head;
	while(p->next!=NULL){
			p=p->next;
	}
	q=p;
	for(i=0;strcmp(phonearray[i].name,"#")!=0;i++){
		fread(&phonearray[i],sizeof(struct node2),1,open);
		s=malloc(sizeof(phonelist));
		strcpy(s->name,phonearray[i].name);
		strcpy(s->phonenum,phonearray[i].phonenum);
		s->next=q->next;
		p->next=s;
		q=s;
	}
}

	



void main(){
	phonelist *s;
	char name[maxsize];
	int i=0;
	int choice=10;
	printf("************����ͨѶ¼************\n");
	head=creatphonelist();
	printf("1*********���������ϵ��**********\n");
	printf("2***********�����ϵ��************\n");
	printf("3************ɾ����ϵ��***********\n");
	printf("4*********��ѯ��ϵ����Ϣ**********\n");
	printf("5*********�޸���ϵ����Ϣ**********\n");
	printf("6****����ϵ����Ϣ���浽�ļ�*******\n");
	printf("7*���ļ��ж�ȡ��ϵ����ӵ�ͨѶ¼**\n");
	printf("8*************����****************\n");
	printf("0**********��������***************\n");
			
	while(choice!=0){
	 
	
	
		scanf("%d",&choice);
		switch(choice){
		case 1:
			output(head);
			break;
		case 2:
			insert(head);
		
			break;
		case 3:	
			printf("������Ҫɾ������ϵ�˵�����\n");
			scanf("%s",&name);
			delete(head,name);
		
			break;
		case 4:	
			printf("������Ҫ��ѯ����ϵ�˵�����\n");
			scanf("%s",&name);
			s=search(head,name);
			if(s!=NULL)
				printf("%10s%15s\n",s->name,s->phonenum);
			else
				printf("%s������ͨѶ¼��\n",name);
			break;
       case 5:	
			printf("������Ҫ�޸ĵ���ϵ�˵�����\n");
			scanf("%s",&name);
			s=search(head,name);
			if(s!=NULL){
				printf("�������µĺ���\n");
		    	scanf("%s",&s->phonenum);
			}
			else
				printf("%s������ͨѶ¼��\n",name);
			break;
		case 6:	
			save(head);
			printf("�ɹ�����Ϣ���浽��ͨѶ¼����\n");
				break;
		case 7:
			open();
			printf("���ļ��������ϵ����Ϣ�ɹ�\n");
			break;

		case 8:	
			system("cls");
		  	break;
	   	case 9:	
			printf("1*********���������ϵ��**********\n");
			printf("2***********�����ϵ��************\n");
			printf("3************ɾ����ϵ��***********\n");
			printf("4*********��ѯ��ϵ����Ϣ**********\n");
			printf("5*********�޸���ϵ����Ϣ**********\n");
			printf("6****����ϵ����Ϣ���浽�ļ�*******\n");
			printf("7*���ļ��ж�ȡ��ϵ����ӵ�ͨѶ¼**\n");
			printf("8*************����****************\n");
			printf("0**********��������***************\n");
		
		    break;
		case 0:
			break;
		default:
			   break;


		}
	 printf("1:��ʾ 2:��� 3:ɾ�� 4 :��ѯ 5:�޸�\n6:���� 7:��ȡ 8:���� 9:��ʾ�˵�\n ");
	}
 
}