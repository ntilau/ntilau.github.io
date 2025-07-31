#include <iostream.h>
#include <cstring.h>

class HugeInt {
friend ostream &operator<<( ostream &, const HugeInt & );
public:
HugeInt( long = 0 ); // conversion/default constructor
HugeInt( const char * ); // conversion constructor
HugeInt operator+( const HugeInt & ); // add another HugeInt
HugeInt operator+( int ); // add an int
HugeInt operator+( const char * ); // add an int in a char *
private:
short integer[ 30 ];
};

// Conversion constructor
HugeInt::HugeInt( long val )
{
int i;
for ( i = 0; i <= 29; i++ )
integer[ i ] = 0; // initialize array to zero
for ( i = 29; val != 0 && i >= 0; i-- ) {
integer[ i ] = val % 10;
val /= 10;
}
}
HugeInt::HugeInt( const char *string )
{
int i, j;
for ( i = 0; i <= 29; i++ )
integer[ i ] = 0;
for ( i = 30 - strlen( string ), j = 0; i <= 29; i++, j++ )
if ( isdigit( string[ j ] ) )
integer[ i ] = string[ j ] - '0';
}
// Addition
HugeInt HugeInt::operator+( const HugeInt &op2 )
{
HugeInt temp;
int carry = 0;
for ( int i = 29; i >= 0; i-- ) {
temp.integer[ i ] = integer[ i ] +
op2.integer[ i ] + carry;
if ( temp.integer[ i ] > 9 ) {
temp.integer[ i ] %= 10;
carry = 1;
}
else carry = 0;
}
return temp;
}
// Addition
HugeInt HugeInt::operator+( int op2 )
{ return *this + HugeInt( op2 ); }
// Addition
HugeInt HugeInt::operator+( const char *op2 )
{ return *this + HugeInt( op2 ); }
ostream& operator<<( ostream &output, const HugeInt &num )
{
int i;
for ( i = 0; ( num.integer[ i ] == 0 ) && ( i <= 29 ); i++ );
if ( i == 30 ) output << 0;
else
for ( ; i <= 29; i++ )
output << num.integer[ i ];
return output;
}
// Test driver for HugeInt class

int main()
{
HugeInt n1( 7654321 ), n2( 7891234 ),
n3( "99999999999999999999999999999" ),
n4( "1" ), n5;
cout << "n1 is " << n1 << "\nn2 is " << n2
<< "\nn3 is " << n3 << "\nn4 is " << n4
<< "\nn5 is " << n5 << "\n\n";
n5 = n1 + n2;
cout << n1 << " + " << n2 << " = " << n5 << "\n\n";
cout << n3 << " + " << n4 << "\n= " << ( n3 + n4 )
<< "\n\n";
n5 = n1 + 9;
cout << n1 << " + " << 9 << " = " << n5 << "\n\n";
n5 = n2 + "10000";
cout << n2 << " + " << "10000" << " = " << n5 << endl;
return 0;
}