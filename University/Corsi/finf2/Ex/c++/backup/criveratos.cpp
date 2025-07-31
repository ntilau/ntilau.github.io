#include <iostream.h>

int main()
{
const int N = 1000;
int i, a[N];
//inizializzazione a 1 del vettore
for (i = 2; i < N; i++) 
	a[i] = 1;
for (i = 2; i < N; i++)  {
	if (a[i]) //se numero primo elimina tutti multipli
		for (int j = i; j*i < N; j++) a[i*j] = 0;
//	cout << a[i] << " ";
	}
//stampa
//cout << "\n";
for (i = 2; i < N; i++)
	if (a[i]) cout << " " << i;
cout << endl;
return 0;
}