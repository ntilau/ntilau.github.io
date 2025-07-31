#include <iostream.h>

int main(){

int a[]= {0,1,2,0,4,0,6,7,8,9};
for(int i = 0; i<10 ; i++)
	if(a[i])
		cout << i << " ";
}