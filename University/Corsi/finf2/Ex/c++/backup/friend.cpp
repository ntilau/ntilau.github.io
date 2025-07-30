#include <iostream.h>

class Count {

public:
friend void setX( Count &, int ); // friend declaration
Count() { x = 0; } // constructor
void print() const { cout << x << endl; } //output
private:
int x; // data member
};
// Can modify private data of Count because
// setX is declared as a friend function of Count
void setX( Count &c, int val ){
c.x = val; // legal: setX is a friend of Count
}

int main()
{
Count counter;
cout << &counter << endl;
cout << "counter.x after instantiation: ";
counter.print();
cout << "counter.x after call to setX friend function: ";
setX( counter, 8 ); // set x with a friend
counter.print();
cout << &(counter) << '\t' << sizeof(counter) << endl;
return 0;
}