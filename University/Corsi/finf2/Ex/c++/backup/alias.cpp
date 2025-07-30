#include <iostream.h>


int main(){

int x = 2;
int &y = x;
y = 3;
int *z = new int;
*z = x;
cout << x << "\t" << &x << "\t" << y << "\t" << &y << "\t" << z << "\t" << &z << "\t" << *z;

}