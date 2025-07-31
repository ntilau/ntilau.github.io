#ifndef HEADER_H
#define HEADER_H
class StatClass{
 public:
  StatClass(unsigned=5);
  ~StatClass();
  void Insert(unsigned);
  double Average();

  StatClass& operator<<(unsigned);

  //************* dopo
  unsigned Max();
  void PrintHistogram();
  //*************

 private:
  unsigned mCurrentPosition;
  unsigned* mpData;
  unsigned mSize;
};

#endif
