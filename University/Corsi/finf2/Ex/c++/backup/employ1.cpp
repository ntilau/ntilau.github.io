// Member function definitions for class Employee
#include <iostream.h>
#include <cstring.h>
#include <cassert.h>

class Employee {
public:
Employee( const char*, const char* ); // constructor
~Employee(); // destructor
const char * getFirstName() const; // return first name
const char * getLastName() const; // return last name
static int getCount(); // return # objects instantiated
private:
char *firstName;
char *lastName;
// static data member
static int count; // number of objects instantiated
};

int Employee::count = 0;
int Employee::getCount() { return count; }

Employee::Employee( const char *first, const char *last ){
firstName = new char[ strlen( first ) + 1 ];
assert( firstName != 0 ); // ensure memory allocated
strcpy( firstName, first );
lastName = new char[ strlen( last ) + 1 ];
assert( lastName != 0 ); // ensure memory allocated
strcpy( lastName, last );
++count; // increment static count of employees
cout << "Employee constructor for " << firstName
<< ' ' << lastName << " called." << endl;
}

Employee::~Employee()
{
cout << "~Employee() called for " << firstName
<< ' ' << lastName << endl;
delete [] firstName; // recapture memory
delete [] lastName; // recapture memory
--count; // decrement static count of employees
}

const char * Employee::getFirstName() const{
// Const before return type prevents client from modifying
// private data. Client should copy returned string before
// destructor deletes storage to prevent undefined pointer
return firstName;
}

const char * Employee::getLastName() const{return lastName;}

int main()
{
cout << "Number of employees before instantiation is "
<< Employee::getCount() << endl; // use class name
Employee *e1Ptr = new Employee( "Susan", "Baker" );
Employee *e2Ptr = new Employee( "Robert", "Jones" );
cout << "Number of employees after instantiation is " << e1Ptr->getCount();
cout << "\n\nEmployee 1: " << e1Ptr->getFirstName() << " " << e1Ptr->getLastName() << "\nEmployee 2: " << e2Ptr->getFirstName() << " " << e2Ptr->getLastName() << "\n\n";
delete e1Ptr; // recapture memory
e1Ptr = 0;
cout << "Number of employees after deletion is " << Employee::getCount() << endl;
delete e2Ptr; // recapture memory
e2Ptr = 0;
cout << "Number of employees after deletion is " << Employee::getCount() << endl;
return 0;
}
