#include<stdio.h>
#include<string.h>
#include<malloc.h>

/*
   m: ���к������Ŀ
   n: ���а������Ŀ
   x: ��Ҫȡ������Ŀ
   y: �������ٳ��ֵĴ���
*/
double pro(int m, int n, int x, int y)
{
	if(y>x) return 0;
	if(y==0) return 1;
	if(y>m) return 0;
	if(x-n>y) return 1;
	double p1 = _______________________;
	double p2 = _______________________;
	return (double)m/(m+n) * p1 + (double)n/(m+n) * p2;
}




void main ( ){	
	int m=20;
	int n=15;
	int x=12;
	int y=10;
	printf("%d",pro(m,  n,  x, y));
	
 }
