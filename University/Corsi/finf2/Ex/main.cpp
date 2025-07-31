#include<iostream>
#include<cstdlib>
#include"header.h"

using namespace std;

int main(){
  StatClass stat_obj;
  const int DIM=10; 
  unsigned data[]={1,2,3,1,5,1,1,1,2,3};

  //stampa
  for(int i=0;i<DIM;i++) cout<<data[i]<<" ";
  //inserisci dati in oggetto
  for(int i=0;i<DIM;i++) stat_obj << data[i];

  cout<<"Media: "<<stat_obj.Average()<<endl;
  stat_obj.PrintHistogram();

  //crea sequenza casuale di dati
  srand(2);
  for(int i=0;i<DIM;i++) data[i]=rand()%10;
  //stampa
  for(int i=0;i<DIM;i++) cout<<data[i]<<" ";
  //inserisci dati in oggetto
  for(int i=0;i<DIM;i++) stat_obj<<data[i];

  cout<<"Media: "<<stat_obj.Average()<<endl;
  stat_obj.PrintHistogram();

  StatClass stat_obj2;
  stat_obj2<<1<<2<<3;
  cout<<"Media: "<<stat_obj2.Average()<<endl;
  stat_obj2.PrintHistogram();

  char c;cin>>c;
  return 0;
}
