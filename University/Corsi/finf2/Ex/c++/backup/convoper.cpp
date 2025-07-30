#include <iostream.h>

template<class C> class Node {
public:
  Node(C aKey):key(aKey), left(0), right(0){};
  Node( Node& A ) { key = A.key;};
  C print(){ return key;};
private:
  C key;
  Node* left;
  Node* right;
};

int main(){
int a = 9;
Node<int>* nodo = new Node<int>(a);
cout << "Nodo creato\nLa chiave e : " << nodo->print() << endl;
Node<int>* nodo1 = nodo;
cout<< "Nodo 1 creato e copiato da \'nodo\'\nInfatti stampa: " << nodo1->print()<< endl;

char b = 'b';
Node<char>* nodo2 = new Node<char>(b);
cout << "Nodo creato\nLa chiave e : " << nodo2->print() << endl;


system("@PAUSE");
}