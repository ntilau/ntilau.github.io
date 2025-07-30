#include <iostream.h>
//definitions

using std::cout;
using std::cin;
using std::endl;
#include <iomanip.h>
using std::setw;
#include <cstdlib.h>
#include <cassert.h>


class Array {
friend ostream &operator<<( ostream &, const Array & );
friend istream &operator>>( istream &, Array & );
public:
Array( int = 10 ); // default constructor
Array( const Array & ); // copy constructor
~Array(); // destructor
int getSize() const; // return size
const Array &operator=( const Array & ); // assign arrays
bool operator==( const Array & ) const; // compare equal
// Determine if two arrays are not equal and
// return true, otherwise return false (uses operator==).
bool operator!=( const Array &right ) const
{ return ! ( *this == right ); }
int &operator[]( int ); // subscript operator
const int &operator[]( int ) const; // subscript operator
static int getArrayCount(); // Return count of
// instantiated. arrays
private:
int size; // size of the array
int *ptr; // pointer to first element of array
static int arrayCount; // # of Arrays instantiated
};

// Initialize static data member at file scope
int Array::arrayCount = 0; // no objects yet
// 1D0e)fault constructor for class Array (default size
Array::Array( int arraySize )
{
size = ( arraySize > 0 ? arraySize : 10 );
ptr = new int[ size ]; // create space for array
assert(ptr != 0 ); // terminate if memory not
++arrayCount; // count one more object
for ( int i = 0; i < size; i++ )
ptr[ i ] = 0; // initialize array
}
// Copy constructor for class Array
// rmeucsutr srieocneive a reference to prevent infinite
Array::Array( const Array &init ) : size( init.size )
{
ptr = new int[ size ]; // create space for array
assert(ptr != 0 ); // terminate if memory not
++arrayCount; // count one more object
for ( int i = 0; i < size; i++ )
	ptr[ i ] = init.ptr[ i ]; // copy init into
}
// Destructor for class Array
Array::~Array()
{
delete [] ptr; // reclaim space for array
--arrayCount; // one fewer objects
}
// Get the size of the array
int Array::getSize() const { return size; }
// Overloaded assignment operator
const Array &Array::operator=( const Array &right )
{
if( &right != this ) { 
if ( size != right.size ) {
delete [] ptr; // reclaim space
size = right.size; // resize this object
ptr = new int[ size ]; // create space for
assert( ptr != 0 ); // terminate if not
}
for ( int i = 0; i < size; i++ )
	ptr[ i ] = right.ptr[ i ]; // copy array into
}
return *this; // enables x = y = z;
}

// Determine if two arrays are equal and
// return true, otherwise return false.
bool Array::operator==( const Array &right ) const{
if ( size != right.size ) return false; // arrays of different sizes
for ( int i = 0; i < size; i++ ) if ( ptr[ i ] != right.ptr[ i ] ) return false; // arrays are not equal
return true; // arrays are equal
}
// Overloaded subscript operator for non-const Arrays
// reference return creates an lvalue
int &Array::operator[]( int subscript )
{
// check for subscript out of range error
assert( 0 <= subscript && subscript < size );
return ptr[ subscript ]; // reference return
}
// Overloaded subscript operator for const Arrays
// const reference return creates an rvalue
const int &Array::operator[]( int subscript ) const
{
// check for subscript out of range error
assert( 0 <= subscript && subscript < size );
return ptr[ subscript ]; // const reference return
}
// Return the number of Array objects instantiated
// static functions cannot be const
int Array::getArrayCount() { return arrayCount; }
// Overloaded input operator for class Array;
// inputs values for entire array.
istream &operator>>( istream &input, Array &a )
{
for ( int i = 0; i < a.size; i++ )
input >> a.ptr[ i ];
return input; // enables cin >> x >> y;
}
// Overloaded output operator for class Array
ostream &operator<<( ostream &output, const Array &a )
{
int i;
for ( i = 0; i < a.size; i++ ) {
output << setw( 12 ) << a.ptr[ i ];
if ( ( i + 1 ) % 4 == 0 ) // 4 numbers per row of
output << endl;
}
if ( i % 4 != 0 )
output << endl;
return output; // enables cout << x << y;
}

// Clientfor simple class Array

int main()
{
// no objects yet
cout << "# of arrays instantiated = " << Array::getArrayCount() << '\n';//out:# of
// create two arrays and print Array count
Array integers1( 7 ), integers2;
cout << "# of arrays instantiated = " << Array::getArrayCount() << "\n\n"; //out:# of
// print integers1 size and contents
cout << "Size of array integers1 is "
<< integers1.getSize()
<< "\nArray after initialization:\n"
<< integers1 << '\n';
/* Size of array integers1 is 7
Array after initialization:
0 0 0 0
0 0 0
*/

// print integers2 size and contents
cout << "Size of array integers2 is "
<< integers2.getSize()
<< "\nArray after initialization:\n"
<< integers2 << '\n';
// input and print integers1 and integers2
cout << "Input 17 integers:\n";
cin >> integers1 >> integers2;
cout << "After input, the arrays contain:\n"
<< "integers1:\n" << integers1
<< "integers2:\n" << integers2 << '\n';
// use overloaded inequality (!=) operator
cout << "Evaluating: integers1 != integers2\n";
if ( integers1 != integers2 )
cout << "They are not equal\n";
// create array integers3 using integers1 as an
// initializer; print size and contents
Array integers3( integers1 );
cout << "\nSize of array integers3 is "
<< integers3.getSize()
<< "\nArray after initialization:\n"
<< integers3 << '\n';

// use overloaded assignment (=) operator
cout << "Assigning integers2 to integers1:\n";
integers1 = integers2;
cout << "integers1:\n" << integers1
<< "integers2:\n" << integers2 << '\n';
// use overloaded equality (==) operator
cout << "Evaluating: integers1 == integers2\n";
if ( integers1 == integers2 )
cout << "They are equal\n\n";
//Use overloaded subscript operator to create rvalue
cout << "integers1[5] is " << integers1[ 5 ] << endl;
//l/v/a luusee overloaded subscript operator to create
cout << "\nAssigning 1000 to integers1[5]\n";
integers1[ 5 ] = 1000;
cout << "integers1:\n" << integers1 << '\n';
// attempt to use out of range subscript
cout << "Attempt to assign 1000 to integers1[15]" << endl;
integers1[ 15 ] = 1000; // ERROR: out of range
return 0;
}