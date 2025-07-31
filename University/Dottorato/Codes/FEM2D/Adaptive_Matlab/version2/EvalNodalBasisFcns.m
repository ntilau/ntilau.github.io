function v=EvalNodalBasisFcns(inodes,enodes)

% v=EvalNodalBasisFcns(inodes,enodes)
%
%   This function evaluates the standard nodal basis functions
%   defined on a triangle with interpolation nodes inodes
%   at the evaluation nodes enodes.  The id by 2 array inodes
%   must store the coordinates of the id interpolation nodes.
%
%   The resulting matrix v is n by id; each column contains the
%   values of one of the basis functions at the n evaluation
%   nodes.

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

% Form the vandermonde-like matrix containing the evaluation nodes:

n=size(enodes,1);
D=zeros(id,n);

x=enodes(:,1)';
y=enodes(:,2)';
l=0;
for i=0:d
   for j=0:i
      l=l+1;
      D(l,:)=x.^(i-j).*y.^j;
   end
end

% Solve the system giving the values:

v=(N\D)';
