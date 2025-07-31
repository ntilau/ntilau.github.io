#include <iostream>

int main(){

double *a = new double(3.1415);
double *b = new double[100];
b[30] = 1976;

cout << *a << "\t\t" << sizeof(*a) << "\t" << sizeof(double) << "\t" << &a << "\t" << a;
cout << "\n";
cout << *b << "\t" << sizeof(*b) << "\t" << sizeof(double) << "\t" << &b << "\t" << b;
cout << "\n";cout << "\n";
for(int i=0; i<=100; i++){
cout << b[i] << "\t";
}
cout << "\n";cout << "\n";
for(int i=0; i<=100; i++){
cout << a[i] << "\t";
}
}