#include<iostream.h>

void swap_greater(int *, int *);
void swap_lesser(int *, int *);

int main()

{
int a[] = { 10, 20, 30, 40 };
int b[] = { 50, 60, 70, 80 };
void (*func)(int *, int *);
int i;
func=swap_greater;
cout << "\nPrimo round\n";
for ( i = 0; i < 4; i++ ){
cout << "\nPrima:\t" << a[i] << "\t" << b[i] << '\n';
cout << "\nBEFORE FUNCTION: " << b;
(*func)(&a[i],&b[i]);
cout << "\nAFTER FUNCTION: " << b;
cout << "\n\nDopo:\t" << a[i] << "\t" << b[i] << '\n';
}

func=swap_lesser;
cout << "\nSecondo Round\n";
for ( i = 0; i < 4; i++ ){
cout << "\nPrima:\t" << a[i] << "\t" << b[i] << '\n';
(*func)(&a[i],&b[i]);
cout << "\nDopo:\t" << a[i] << "\t" << b[i] << '\n';
}

return 0;
}

void swap_greater(int *a, int *b){
cout << "\nIN THE FUNCTION1: " << b;
int tmp;
if(*a < *b){
tmp=*a;
*a=*b;
*b=tmp;
cout << "\nIN THE FUNCTION2: " << b;
}
}
void swap_lesser(int *a, int *b){
int tmp;
if(*a > *b){
tmp=*a;
*a=*b;
*b=tmp;
}
}