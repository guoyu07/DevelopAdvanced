#include<stdio.h>
void fun(double dTestNo, int iBase)
{
	int iT[8];
	int iNo;

	printf("ʮ������С�� %f ת���� %d ������Ϊ: ",dTestNo, iBase);

	for(iNo=0;iNo<8;iNo++)
	{
		dTestNo *= iBase;
		iT[iNo] = dTestNo/1;
		if(dTestNo>=1) dTestNo -= iT[iNo];
	}
	
	printf("0.");
	for(iNo=0; iNo<8; iNo++) printf("%d", iT[iNo]);
	printf("\n");
}

void main ( )
{	
	double dTestNo= 0.795;
	int iBase;

	for(iBase=2;iBase<=9;iBase++)
		fun(dTestNo,iBase);
	printf("\n");
}
