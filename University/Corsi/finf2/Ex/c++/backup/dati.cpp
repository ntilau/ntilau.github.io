#include <iostream.h>

void main(){

int a = 2;
int *b = &a;
int &c = a;
int *d = new int;

cout << "Indirizzo di a: " << &a << endl;
cout << "Contenuto di a: " << a << endl;
cout << "Indirizzo di b: " << &b << endl;
cout << "Contenuto di b: " << b << endl;
cout << "Contenuto del puntato da b: " << *b << endl;
cout << "Indirizzo di c: " << &c << endl;
cout << "Contenuto di c: " << c << endl;
cout << "Indirizzo di d: " << &d << endl;
cout << "Contenuto del puntato da d: " << *d << endl;

*d = a;
cout << "dopo assegnazione:\n";

cout << "Indirizzo di a: " << &a << endl;
cout << "Contenuto di a: " << a << endl;
cout << "Indirizzo di b: " << &b << endl;
cout << "Contenuto di b: " << b << endl;
cout << "Contenuto del puntato da b: " << *b << endl;
cout << "Indirizzo di c: " << &c << endl;
cout << "Contenuto di c: " << c << endl;
cout << "Indirizzo di d: " << &d << endl;
cout << "Contenuto del puntato da d: " << *d << endl;


}