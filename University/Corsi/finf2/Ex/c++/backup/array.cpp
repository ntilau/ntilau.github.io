#include <iostream.h>

void f(const int* const, const int);

main(){
int array[]={0,1,2,3,4,12,6,7,8,9};
int* a=array;
f(a,10);
int *address_array = array + 5 ;
cout << "\n" << array << "\t" << address_array;
cout << "\nE il contenuto: " << *array << " " << *address_array;
}

void f(const int* const array, const int dim){
for(int i=0;i<dim;i++)
cout<<*(array + i); //si può solo leggere il dato
}