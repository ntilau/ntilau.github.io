#include <iostream>
#include <cassert>

using namespace std;

template<class T>
class Queue{
public:
  Queue(int aSize):mSize(aSize),mHead(0),mTail(0){mStorage=new T[mSize];}
  ~Queue(){delete[] mStorage;}
  void Push(T aValue)
  {
    if (mTail==mSize) mTail=0;//make circular
    mStorage[mTail]=aValue;
    mTail+=1;
  }
  T Pop()
  {
    assert(mTail!=mHead);
    T value=mStorage[mHead];
    mHead+=1;
    if (mHead==mSize) mHead=0;//make circular
    return value;
  }
private:
  int mSize;
  int mHead;//points to current head element
  int mTail;//points to element after last inserted (first free element)
  T* mStorage;
};

class Node{
public:
  Node(int aKey):mKey(aKey),mpLeft(0),mpRight(0){}
  Node* Clone(){return new Node(mKey);}
public:
  int mKey;
  Node* mpLeft;
  Node* mpRight;
};

class Tree{
public:
  Tree();
  ~Tree();
  Tree(const Tree& aTreeToCopy);
  Tree& operator=(const Tree& aTreeToCopy);

  int Size()const;
  void Input(const int aValue);
  void Output(ostream& out)const;
  void OutputPostOrder(ostream& out)const;
  bool operator==(const Tree& aT)const;
private:
  void mCopyConstructor(Node* apNodeCurrent, Node* apNodeToCopy);
  void mDistructor(Node* apNode);
  int mSize(Node* apNode)const;
  void mOutputPostOrder(Node* apNode,ostream& out)const;
  bool mTestForEquality(const Node* apNodeX, const Node* apNodeY)const;
private:
  Node* mpRoot;
};

Tree::Tree():mpRoot(0){}

Tree::Tree(const Tree& aTreeToCopy)
{
  *this=aTreeToCopy;
}

Tree& Tree::operator=(const Tree& aTreeToCopy)
{
  if (aTreeToCopy.mpRoot!=0) 
    {
      mpRoot=aTreeToCopy.mpRoot->Clone();
      mCopyConstructor(mpRoot,aTreeToCopy.mpRoot);
    }
  else {}
  return *this;
}

void Tree::mCopyConstructor(Node* apNodeCurrent, Node* apNodeToCopy)
{
  if (apNodeToCopy->mpLeft!=0)
    {
      apNodeCurrent->mpLeft=apNodeToCopy->mpLeft->Clone();
      mCopyConstructor(apNodeCurrent->mpLeft, apNodeToCopy->mpLeft);
    }
  if (apNodeToCopy->mpRight!=0)
    {
      apNodeCurrent->mpRight=apNodeToCopy->mpRight->Clone();
      mCopyConstructor(apNodeCurrent->mpRight, apNodeToCopy->mpRight);
    }
}

Tree::~Tree()
{
  mDistructor(mpRoot);
}

void Tree::mDistructor(Node* apNode)
{
  if (apNode !=0)
    {
      mDistructor(apNode->mpLeft);
      mDistructor(apNode->mpRight);
      delete apNode;
    }
}

int Tree::Size()const
{
  return mSize(mpRoot);
}

int Tree::mSize(Node* apNode)const
{
  if (apNode==0) return 0;
  return 1+mSize(apNode->mpLeft)+mSize(apNode->mpRight);
}

void Tree::Input(const int aValue)
{
  int  size=Size();
  if (size==0) mpRoot=new Node(aValue);
  else {
    Queue<Node*> local_queue(2*size);
    Node* cursor=mpRoot;
    //iterate until we find a node with either a left or right null child
    while (cursor->mpLeft!=0 && cursor->mpRight!=0)
      {
	local_queue.Push(cursor->mpLeft);
	local_queue.Push(cursor->mpRight);
	cursor=local_queue.Pop();
      }
    //insert substituting null child
    if (cursor->mpLeft==0) cursor->mpLeft=new Node(aValue);
    else cursor->mpRight=new Node(aValue);
  }
}

void Tree::Output(ostream& out)const
{
  Queue<Node*> local_queue(2*Size());
  Node* cursor=mpRoot;
  while (cursor!=0)
    {      
      out<<cursor->mKey<<" ";
      local_queue.Push(cursor->mpLeft);
      local_queue.Push(cursor->mpRight);
      cursor=local_queue.Pop();
    }
}

void Tree::OutputPostOrder(ostream& out)const
{
  mOutputPostOrder(mpRoot,out);
}

void Tree::mOutputPostOrder(Node* apNode, ostream& out)const
{
  if (apNode!=0)
    {
      mOutputPostOrder(apNode->mpLeft, out);
      mOutputPostOrder(apNode->mpRight, out);
      out<<apNode->mKey<<" ";
    }
}

bool Tree::operator==(const Tree& aT)const
{
  return mTestForEquality(mpRoot,aT.mpRoot);
}

bool Tree::mTestForEquality(const Node* apNodeX, const Node* apNodeY)const
{
  if (apNodeX==0 && apNodeY!=0) return false;
  else if (apNodeX!=0 && apNodeY==0) return false;
  else if (apNodeX==0 && apNodeY==0) return true;
  else return apNodeX->mKey==apNodeY->mKey && mTestForEquality(apNodeX->mpLeft,apNodeY->mpLeft) && mTestForEquality(apNodeX->mpRight,apNodeY->mpRight);
}

ostream& operator<<(ostream& out, const Tree& aTree)
{
  aTree.Output(out);
  return out;
}

int main(){

  const int DIM=10;

  Tree tx;
  for (int i=0;i<DIM;i++)
    tx.Input(i);
  cout<<tx<<endl;
  tx.OutputPostOrder(cout);
  cout<<endl;

  Tree ty;
  ty=tx;
  cout<<ty<<endl;

  Tree tz;
  for (int i=9;i>=0;i--)
    tz.Input(i);
  cout<<tz<<endl;

  cout<<"I due alberi ["<<tx<<"] e ["<<ty<<"] sono ...";
  if (tx==ty) cout<<"uguali"<<endl;
  else cout<<"diversi"<<endl;

  cout<<"I due alberi ["<<tx<<"] e ["<<tz<<"] sono ...";
  if (tx==tz) cout<<"uguali"<<endl;
  else cout<<"diversi"<<endl;

  return 0;
}
