#include<iostream.h>


template<class T> class complex {
  public:
    complex(int passed_size=10){ size=passed_size; C = new T[size];};
  private:
    T *C;
	int size;
};


template<typename T1 , typename T2> void f( T1, T2);
template<typename T> void f( T );
template<typename T> void f( T , T );
template<typename T> void f( T*);
template<typename T> void f( T*, T );
template<typename T> void f( T, T* );
template<typename T> void f( int, *T );
template<> void f<int>( int );
void f( int , double );
void f( int );

int main(void){

int i = 0;
double d = 0;
float ff = 0;
complex<double> c ;

f(i);
f<int>(i);
f(i,i);//irrisovibile
f(c);
f(i,ff);//irrisovibile
f(i, d);//irrisovibile
f(c, &c);
f(i, &d);
f(&d, d);
f(&d);
f( d , &i);
f(&i, &i);

}

template<typename T1 , typename T2> void f( T1, T2){
  cout << "Usata la 1" << endl;
}
template<typename T> void f( T ){
  cout << "Usata la 2" << endl;
}
template<typename T> void f( T , T ){
  cout << "Usata la 3" << endl;
}
template<typename T> void f( T*){
  cout << "Usata la 4" << endl;
}
template<typename T> void f( T*, T ){
  cout << "Usata la 5" << endl;
}
template<typename T> void f( T, T* ){
  cout << "Usata la 6" << endl;
}
template<typename T> void f( int, T* ){
  cout << "Usata la 7" << endl;
}
template<> void f<int>( int ){
  cout << "Usata la 8" << endl;
}
void f( int , double ){
  cout << "Usata la 9" << endl;
}
void f( int ){
  cout << "Usata la 10" << endl;
}