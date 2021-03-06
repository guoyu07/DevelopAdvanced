#include "stdio.h"
#include "malloc.h"
#include "string.h"
#define  maxsize 12
#define  size 100

/*定义节点*/

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
	printf("请依次输入姓名和号码以#结束输入\n");
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
	printf("请依次输入姓名和号码\n");
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
			printf("%s已从通讯录中删除\n",name);
		}
		else
			printf("%s不存在通讯录中\n",name);
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
	if((out=fopen("通讯录","wb"))==NULL){
			printf("打不开文件\n");
			return;
	}

	p=head->next;
	while(p!=NULL){
		strcpy(phonearray[i].name,p->name);
		strcpy(phonearray[i].phonenum,p->phonenum);
		if(fwrite(&phonearray[i],sizeof(struct node2),1,out)!=1)
		    printf("写入信息失败\n");
		i++;
		p=p->next;
	}
	 strcpy(phonearray[i].name,"#");
	 if(fwrite(&phonearray[i],sizeof(struct node2),1,out)!=1)
		   printf("写入信息失败\n");
	 fclose(out);
}

void open(){
	int i;
	phonelist *p,*q,*s;

	FILE*open;
	if((open=fopen("通讯录","rb"))==NULL){
			printf("phonelist文件不存在无法读取");
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
	printf("************建造通讯录************\n");
	head=creatphonelist();
	printf("1*********输出所有联系人**********\n");
	printf("2***********添加联系人************\n");
	printf("3************删除联系人***********\n");
	printf("4*********查询联系人信息**********\n");
	printf("5*********修改联系人信息**********\n");
	printf("6****将联系人信息保存到文件*******\n");
	printf("7*从文件中读取联系人添加到通讯录**\n");
	printf("8*************清屏****************\n");
	printf("0**********结束输入***************\n");
			
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
			printf("请输入要删除的联系人的姓名\n");
			scanf("%s",&name);
			delete(head,name);
		
			break;
		case 4:	
			printf("请输入要查询的联系人的姓名\n");
			scanf("%s",&name);
			s=search(head,name);
			if(s!=NULL)
				printf("%10s%15s\n",s->name,s->phonenum);
			else
				printf("%s不存在通讯录中\n",name);
			break;
       case 5:	
			printf("请输入要修改的联系人的姓名\n");
			scanf("%s",&name);
			s=search(head,name);
			if(s!=NULL){
				printf("请输入新的号码\n");
		    	scanf("%s",&s->phonenum);
			}
			else
				printf("%s不存在通讯录中\n",name);
			break;
		case 6:	
			save(head);
			printf("成功将信息保存到【通讯录】里\n");
				break;
		case 7:
			open();
			printf("从文件中添加联系人信息成功\n");
			break;

		case 8:	
			system("cls");
		  	break;
	   	case 9:	
			printf("1*********输出所有联系人**********\n");
			printf("2***********添加联系人************\n");
			printf("3************删除联系人***********\n");
			printf("4*********查询联系人信息**********\n");
			printf("5*********修改联系人信息**********\n");
			printf("6****将联系人信息保存到文件*******\n");
			printf("7*从文件中读取联系人添加到通讯录**\n");
			printf("8*************清屏****************\n");
			printf("0**********结束输入***************\n");
		
		    break;
		case 0:
			break;
		default:
			   break;


		}
	 printf("1:显示 2:添加 3:删除 4 :查询 5:修改\n6:保存 7:读取 8:清屏 9:显示菜单\n ");
	}
 
}