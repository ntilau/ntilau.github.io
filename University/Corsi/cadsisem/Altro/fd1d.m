function [x,f] = f1d1(N,k)

dx = 1/(N-1);

if (N-2==1)
  A(1,1) = 2/dx^2-k^2;
  b(1)= 1/dx^2;
else
  A(1,1) = 2/dx^2-k^2;
  A(1,2) = -1/dx^2;
  for i=2:N-3
    A(i,i-1) = -1/dx^2;
    A(i,i) = 2/dx^2-k^2;
    A(i,i+1) = -1/dx^2;
  end;
  A(N-2,N-3) = -1/dx^2;
  A(N-2,N-2) = 2/dx^2-k^2;
  b = zeros(N-2,1);
  b(N-2) = 2/dx^2;
	b
end;

f(2:N-1)=inv(A)*b
f(1)=0;
f(N)=2.;

x=((1:N)-1)/(N-1); 