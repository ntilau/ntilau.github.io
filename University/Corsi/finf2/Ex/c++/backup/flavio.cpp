#include<iostream.h>
#include<stdlib.h>

struct Node{ int item; Node* next;};
void main(int argc, char * argv[]){
int i, N = atoi(argv[1]), M = atoi(argv[2]);
Node * t = new Node;
//cout << "\n" << t << '\n' << &t->item;
t->item=1;
t->next = t;
//cout << "\n" << &t->next << '\n' << &t->next->item;
Node * x = t;
for (i = 2; i <= N; i++){ //creazione della lista
x->next = new Node;
x->next->item=i;
x->next->next=t;
x=x->next;
}
//cout << "\n" << t << " che dovrebbe essere uguale a " << &(x->next->item) << "\nPoi si ha: ";
Node *z = t;
do { //stampa
cout << z->item << " ";
z = z->next;
}
while(z != t);


while (x != x->next){ //eliminazione
for (i = 1; i < M; i++){
cout << "\n" << t->item << " -> " << (x->next->item);
x = x->next; //spostamento
}
cout << "\n\n";
x->next = x->next->next;
}
cout << "\n" << x->item << '\n' << x->next->item << " = " << t->item << endl;//stampa l’ultimo elemento

}