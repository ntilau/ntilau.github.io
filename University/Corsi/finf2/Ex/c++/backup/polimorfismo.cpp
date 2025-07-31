#include<iostream.h>

class Base{
public:
Base(int i=0){b=i;}
void print(){cout<<"Base:"<<b;}
private:
int b;
};
class Deriv:public Base{
public:
Deriv(int i=0, int z=0):Base(i){d=z;}
void print(){cout<<"Deriv:"<<d;}
private:
int d;
};

void main(){
Deriv dObj(10,20);
Base* objPtr=&dObj;
objPtr->print(); //Stampa: Deriv:20
}