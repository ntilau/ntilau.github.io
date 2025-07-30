#include<iostream.h>

class Tempo{
public:
Tempo(int h=0, int m=0){set(h,m);}
void set(int h, int m){setH(h);setM(m);}
Tempo & setH(int h);
Tempo & setM(int m);
void print(){cout<<ora<<":"<<min;}
private:
int ora, min;
};

Tempo & Tempo::setH(int h){
ora=h;
cout << "indirizzo in setH: " << this << endl;
return *this;
}
Tempo & Tempo::setM(int m){
min=m;
cout << "indirizzo in setM: " << this << endl;
return *this;
}

void main(){
Tempo t(10,20);
cout << "indirizzo t: " <<&t << endl;
t.setH(11).setM(15);
t.setH(2).print(); //OK
//t.print().setM(2); //ERROR
}