function [O1,O2,O3]=EvalNodalBasisGrads(inodes,enodes,w)

% [Vx,Vy]=EvalNodalBasisGrads(inodes,enodes)
%         or
% [Grads,Vx,Vy]=EvalNodalBasisGrads(inodes,enodes,w)
%
%   This function evaluates the partial derivatives of the
%   standard nodal basis functions defined on a triangle
%   with interpolation nodes inodes at the evaluation nodes
%   enodes.  The id by 2 array inodes must store the
%   coordinates of the id interpolation nodes.
%
%   Upon exit, the n by id arrays Vx and Vy contain the
%   partial derivatives with respect to x and y, respectively,
%   (as columns) of the id functions at the n points.
%
%   If the optional argument w is included, the gradients of
%   the linear combination of the basis functions (with
%   the weights in the linear combination coming from w) are
%   computed instead.  In this case, the output is a 2 by n
%   array.  Vx and Vy are then returned, if requested, as the
%   second and third arguments.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Determine id and d (id=(d+1)*(d+2)/2)):

id=size(inodes,1);
d=round((sqrt(8*id+1)-3)/2);
if (d+2)*(d+1)/2~=id
   error('The number of nodes must be (d+2)(d+1)/2 for some integer d')
end

% Form the vandermonde-like matrix defined by the interpolation nodes:

N=zeros(id);

x=inodes(:,1)';
y=inodes(:,2)';
l=0;
for i=0:d
   for j=0:i
      l=l+1;
      N(l,:)=x.^(i-j).*y.^j;
   end
end

% Form the vandermonde-like matrix defined by the evaluation nodes
% (for partial derivative with respect to x):

n=size(enodes,1);
Cx=zeros(id,n);

x=enodes(:,1)';
y=enodes(:,2)';
l=0;
for i=0:d
   for j=0:i
      l=l+1;
      if (i>0 & j<i)
         Cx(l,:)=(i-j)*x.^(i-j-1).*y.^j;
      end
   end
end

% Form the vandermonde-like matrix defined by the evaluation nodes
% (for partial derivative with respect to y):

Cy=zeros(id,n);

x=enodes(:,1)';
y=enodes(:,2)';
l=0;
for i=0:d
   for j=0:i
      l=l+1;
      if j>0
         Cy(l,:)=j*x.^(i-j).*y.^(j-1);
      end
   end
end

% Solve the system giving the values:

T=N\[Cx,Cy];
O1=T(:,1:n)';
O2=T(:,n+1:2*n)';

if nargin==3
   Grads=[(O1*w)';(O2*w)'];
   if nargout>1
      O3=O2;
      O2=O1;
   end
   O1=Grads;
end
