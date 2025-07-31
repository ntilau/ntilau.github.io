#include<iostream.h>


void main(){

  int num, max_num=-1;
  while(cin >> num)
    if(num>max_num) max_num=num;
  cout<<"Il Massimo e: "<< max_num;
}