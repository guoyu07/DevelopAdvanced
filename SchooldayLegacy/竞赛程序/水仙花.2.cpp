#include <iostream>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

using namespace std;

char *multi(char *p, char *q);//��˷�
void chushi();//��nums��value���������ʼ��
char *convert(int a);//������ת�����ַ���
void add(char* A0,char* A1,char* A2,char* A3,char* A4,char* A5,char* A6,char* A7,char* A8,char* A9,char* c);
//��A0 - A9ȫ����������������õ�c��
bool judge(int i0, int i1, int i2, int i3, int i4, int i5, int i6, int i7, int i8, int i9, char *p);
//�ж�i0 - i9ö�ٳ��ֵĴ�����p�г��ֵĴ����Ƿ�һ�£����һ����˵������Ϊˮ�ɻ���

char nums[10][22];//���0-9��21�η�
char value[10][22][80];//���0-9���ִ����ĺͣ�����0�����ˮ�ɻ����г��ֵĴ���Ϊ1�Σ���Ϊ0 �� ����2��ˮ�ɻ������ִ���Ϊ2������
//2^21*2��2��21�η�����2���Դ�����..�Ϳ��Եõ�
/**
 * 0^21*0 0^21*1 0^21*2 0^21*3.......0^21*9
 * 1^21*0 1^21*1 0^21*2..............1^21*9
 * 2^21*0......�������������ȥ���Ա��Ժ��ʹ��
 */

void main()
{
	//����ִ�е�ʱ������Ҫ25s����

	int start = clock();//��ʱ��ʼ

	int count = 0;//�Ѿ�֪����21λˮ�ɻ��������������Ե�count==2��ʱ���������... ��Ȼ��Ҳ���Բ�������ȫ��ѭ������Ҫ40s���Ұ�

	chushi();

	char ans[30];//���ˮ�ɻ�����

	//��ö�ٵķ���ö�ٳ�0-9��ˮ�ɻ����г��ֵĴ���...	
	//զһ����˶���룬��ʵ�ܺ���⣬��0 - 9 ���ֵĴ����������������Ծ�д��10��ѭ��...

for(int i9=0;i9<=9;i9++)//ö�ٴ�9��ʼ����Ϊ9���ֵĴ������ֻ����9�Σ��������10����9^21��22λ��
 {
  for(int i0=0;i0<=20;i0++)//��һ������Ϊ0������0���ֵ�������λ20�Σ�����ĽԿɳ���21��
  {
   if(i0+i9==21)
   {
    add(value[0][i0],value[1][0],value[2][0],value[3][0],value[4][0],value[5][0],value[6][0],value[7][0],value[8][0],value[9][i9],ans);
   //      ��������õ�����ǰ��ŵ�0 - 9���ִ�����21�η���0������i0��,1������0��.....9������i9�Ρ�
	if(ans[0]!='0' && judge(i0,0,0,0,0,0,0,0,0,i9,ans))  //ans[0]!='0'��֤ansΪ21λ
    {
     cout<<ans<<endl;
     count++;
	 /*
     if(count==2)
     {
		 int end = clock();
		 cout<<"��ʱ��"<<end - start<<"����"<<endl;
		 return;
     }
	 */
    }
    break; //��Ϊi0+i9�Ĵ����Ѿ���21���ˣ�����ٶ�һ�εĻ��ǿ϶��ͳ�����21��...����ֱ������ѭ��..
   }



   for(int i1=0;i1<=21;i1++)
   {
    if(i0+i1+i9==21)
    {
     add(value[0][i0],value[1][i1],value[2][0],value[3][0],value[4][0],value[5][0],value[6][0],value[7][0],value[8][0],value[9][i9],ans);
     if(ans[0]!='0' && judge(i0,i1,0,0,0,0,0,0,0,i9,ans))
     {
      cout<<ans<<endl;
      count++;
      if(count==2)
      {
		  int end = clock();
		  cout<<"��ʱ��"<<end - start<<"����"<<endl;
		  return ;
      }
     }
     break;
    }
    for(int i2=0;i2<=21;i2++)
    {
     if(i0+i1+i2+i9==21)
     {
      add(value[0][i0],value[1][i1],value[2][i2],value[3][0],value[4][0],value[5][0],value[6][0],value[7][0],value[8][0],value[9][i9],ans);
      if(ans[0]!='0' && judge(i0,i1,i2,0,0,0,0,0,0,i9,ans))
      {
       cout<<ans<<endl;
       count++;
       if(count==2)
       {
		   int end = clock();
		   cout<<"��ʱ��"<<end - start<<"����"<<endl;
	       return ;
       }
      }
      break;
     }
     for(int i3=0;i3<=21;i3++)
     {
      if(i0+i1+i2+i3+i9==21)
      {
       add(value[0][i0],value[1][i1],value[2][i2],value[3][i3],value[4][0],value[5][0],value[6][0],value[7][0],value[8][0],value[9][i9],ans);
       if(ans[0]!='0' && judge(i0,i1,i2,i3,0,0,0,0,0,i9,ans))
       {
        cout<<ans<<endl;
        count++;
        if(count==2)
        {
			int end = clock();
			cout<<"��ʱ��"<<end - start<<"����"<<endl;
			return ;
        }
       }
       break;
      }
      for(int i4=0;i4<=21;i4++)
      {
       if(i0+i1+i2+i3+i4+i9==21)
       {
        add(value[0][i0],value[1][i1],value[2][i2],value[3][i3],value[4][i4],value[5][0],value[6][0],value[7][0],value[8][0],value[9][i9],ans);
        if(ans[0]!='0' && judge(i0,i1,i2,i3,i4,0,0,0,0,i9,ans))
        {
         cout<<ans<<endl;
         count++;
         if(count==2)
         {
			int end = clock();
			cout<<"��ʱ��"<<end - start<<"����"<<endl;
			return ;
         }
        }
        break;
       }
       for(int i5=0;i5<=21;i5++)
       {
        if(i0+i1+i2+i3+i4+i5+i9==21)
        {
         add(value[0][i0],value[1][i1],value[2][i2],value[3][i3],value[4][i4],value[5][i5],value[6][0],value[7][0],value[8][0],value[9][i9],ans);
         if(ans[0]!='0' && judge(i0,i1,i2,i3,i4,i5,0,0,0,i9,ans))
         {
          cout<<ans<<endl;
          count++;
          if(count==2)
          {
			int end = clock();
			cout<<"��ʱ��"<<end - start<<"����"<<endl;
			return ;
          }
         }
         break;
        }
        for(int i6=0;i6<=21;i6++)
        {
         if(i0+i1+i2+i3+i4+i5+i6+i9==21)
         {
          add(value[0][i0],value[1][i1],value[2][i2],value[3][i3],value[4][i4],value[5][i5],value[6][i6],value[7][0],value[8][0],value[9][i9],ans);
          if(ans[0]!='0' && judge(i0,i1,i2,i3,i4,i5,i6,0,0,i9,ans))
          {
           cout<<ans<<endl;
           count++;
           if(count==2)
           {
			int end = clock();
			cout<<"��ʱ��"<<end - start<<"����"<<endl;
            return ;
           }
          }
          break;
         }
         for(int i7=0;i7<=21;i7++)
         {
          if(i0+i1+i2+i3+i4+i5+i6+i7+i9==21)
          {
           add(value[0][i0],value[1][i1],value[2][i2],value[3][i3],value[4][i4],value[5][i5],value[6][i6],value[7][i7],value[8][0],value[9][i9],ans);
           if(ans[0]!='0' && judge(i0,i1,i2,i3,i4,i5,i6,i7,0,i9,ans))
           {
            cout<<ans<<endl;
            count++;
            if(count==2)
            {
				int end = clock();
				cout<<"��ʱ��"<<end - start<<"����"<<endl;
				return ;
            }
           }
           break;
          }
          for(int i8=0;i8<=21;i8++)
          {
           if(i0+i1+i2+i3+i4+i5+i6+i7+i8+i9==21)
           {
            add(value[0][i0],value[1][i1],value[2][i2],value[3][i3],value[4][i4],value[5][i5],value[6][i6],value[7][i7],value[8][i8],value[9][i9],ans);
            if(ans[0]!='0' && judge(i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,ans))
            {
             cout<<ans<<endl;
             count++;
             if(count==2)
             {
				int end = clock();
				cout<<"��ʱ��"<<end - start<<"����"<<endl;
				return ;
             }
            }
            break;
           }
          } //i8
         } //i7
        } //i6
       } //i5
      } //i4
     } //i3
    } //i2
   } //i1
  } //i0
 } //i9



	
}  

char *convert(int a)//������ת�����ַ���
{
	char *c = new char[3];

	if(a >  10)//��Ϊֻ�õĵ�21һ�µ�ת��������ֻ������λ����ת��
	{
		c[0] = a / 10 + '0';
		c[1] = a % 10 + '0';
		c[2] = '\0';
	}
	else
	{
		c[0] = a + '0';
		c[1] = '\0';
	}

	return c;
}

void chushi()
{
	int i, j;
	 
	strcpy(nums[0], "0");
	strcpy(nums[1], "1");

	for(i = 2 ; i <= 9; i++)
	{
		char c[2];
		c[0] = i + '0';
		c[1] = '\0';

		//cout<<c<<endl;

		strcpy(nums[i], c);//��c��ֵ��nums[i]

		for(j = 1; j < 21; j++)//��Ϊnums[i]�г�ֵ�ˣ�����ֻ��ѭ��20��
		{
			strcpy(nums[i], multi(nums[i], c));//nums[i]��õ�0-9��21�η�
		}

		
	}	




	for(i = 0; i < 10; i++)
	{
		for(j = 0; j < 22; j++)
		{
			strcpy(value[i][j], multi(nums[i], convert(j)));//value[i][j]�õ�0 - 9���ִ��� * 0 - 9��21��
		}
	}
	


}


char *multi(char *p, char *q)//��˷�����ϸ���룬�ñ�дд�Ϳ��Կ�����
{
	int maxLen, minLen, i, j;

	char *min, *max;
	
	int *a = new int[100];

	if(strlen(p) > strlen(q))
	{
		maxLen = strlen(p);
		minLen = strlen(q);
		
		min = q;
		max = p;
	}
	else
	{
		maxLen = strlen(q);
		minLen = strlen(p);

		min = p;
		max = q;
	}

	memset(a, 0, 100);//���ַ�����0

	int length = maxLen;

	char *c = new char[50];

	for(i = minLen - 1 ; i >= 0 ; i--)
	{
		for(j = 0 ; j < maxLen ; j++)
		{
			a[j] += (max[j] - '0') * (min[i] - '0');//����������a[j]��
		}

		if(i > 0)
		{
			for(int k = length - 1 ; k >= 0 ; k--)//���i>0��˵������ǰ�滹��λ��������Ľ��Ҫ�����ƶ�һλ
			{
				a[k + 1] = a[k]; 
			}
			a[0] = 0;
			length ++;
		}
	}



	for(i = length - 1 ; i > 0 ; i--)
	{
		a[i - 1] += a[i] / 10;//��ʮ��һ
		a[i] %= 10;
	}


	if(a[0] > 9)//��a[0] > 9��ʱ����˵��λ������
	{
		int temp = a[0];

		a[0] %= 10;

		temp /= 10;

		while(temp)
		{
			for(i = length - 1 ; i >= 0 ; i--)//����λ��
				a[i + 1] = a[i];
	
			a[0] = temp % 10;
			length ++;
			temp /= 10;
		}

	}

	for(i = 0; i < 21 - length; i++)//����������21λ����ǰ��0
		c[i] = '0';

	int k = 0;

	for(i = 21 - length; i < 21; i++)
		c[i] = a[k++] + '0';


	c[i] = '\0';


	return c;
}

void add(char* A0,char* A1,char* A2,char* A3,char* A4,char* A5,char* A6,char* A7,char* A8,char* A9,char* c)
{
	int result[21] = {0};

	int i;

	for(i = 0; i < 21; i++)
	{
		result[i] = A0[i] - '0' + A1[i] - '0' + A2[i] - '0' + A3[i] - '0' + 
			A4[i] - '0' + A5[i] - '0' + A6[i] - '0' + A7[i] - '0' + A8[i] - '0' + A9[i] - '0';
		//��ÿһλ��������
	}

	for(i = 20; i > 0; i--)
	{
		result[i - 1] += result[i] / 10;
		result[i] %= 10;//��ʮ��һ
	}

	if(result[0] > 10 || result[0] == 0) //λ������21λ����λ������21λ����ǰ����
	{
		return;
	}

	for(i = 0; i < 21; i++)
		c[i] = result[i] + '0';

	c[i] = '\0';

}

bool judge(int i0, int i1, int i2, int i3, int i4, int i5, int i6, int i7, int i8, int i9, char *p)
{
	int times[10];

	int i, result = 0;
	for(i = 0; i < 10; i++)
		times[i] = 0;

	for(i = 0; i < strlen(p); i++)
		times[p[i] - '0']++;
	//ÿһλ���бȽ�

	if(i0 == times[0] && i1 == times[1] && i2 == times[2] && i3 == times[3] && i4 == times[4] &&
		times[5] == i5 && i6 == times[6] && times[7] == i7 && i8 == times[8] && i9 == times[9])
		return true;

	return false;
}

