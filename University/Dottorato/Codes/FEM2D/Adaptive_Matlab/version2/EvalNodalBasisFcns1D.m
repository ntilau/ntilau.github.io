function v=EvalNodalBasisFcns1D(t,x)

% v=EvalNodalBasisFcns1D(inodes,enodes)
%
%   This function evaluates the standard nodal basis functions
%   defined on an interval with interpolation nodes inodes
%   at the evaluation nodes enodes.  The d+1 by 1 array inodes
%   must store the coordinates of the d+1 interpolation nodes.
%
%   The resulting matrix v is n by d+1; each column contains the
%   values of one of the basis functions at the n evaluation
%   nodes.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Determine d

d=size(t,1)-1;

% Form the vandermonde-like matrix defined by the interpolation nodes:

N=zeros(d+1);
N(1,:)=ones(1,d+1);

for i=2:d+1
   N(i,:)=N(i-1,:).*t';
end

% Form the vandermonde-like matrix containing the evaluation nodes:

k=size(x,1);
C=zeros(d+1,k);
C(1,:)=ones(1,k);

for i=2:d+1
   C(i,:)=C(i-1,:).*x';
end

% Solve the system giving the values:

v=(N\C)';
