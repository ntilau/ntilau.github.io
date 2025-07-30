#include<iostream.h>
using namespace std;
void main(){

const int SIZE=100;
char buffer1[SIZE];
cout << "Inserire una frase:" << endl; //Due parole
cin.getline(buffer1, SIZE, '\n');
cout << "La frase e: "<< buffer1 << endl;//La frase è: Due parole
}