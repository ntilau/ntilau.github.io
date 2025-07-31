function x=GaussSeidel1(A,b,x,k)

% x=GaussSeidel1(A,b,x,k)
%
%   This function updates the estimate x of the
%   solution to Ax=b by applying k Gauss-Seidel
%   iterations.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

M=tril(A);
N=-triu(A,1);
for i=1:k
   x=M\(N*x+b);
end

