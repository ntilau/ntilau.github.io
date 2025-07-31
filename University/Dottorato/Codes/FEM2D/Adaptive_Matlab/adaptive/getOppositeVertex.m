function i3=getOppositeVertex(T,j,i1,i2)

% i3=getOppositeVertex(T,j,i1,i2)
%
%   This function returns the (index of the ) third
%   vertex of the jth triangle of mesh T, when two
%   vertices have indices i1 and i2.
%
%   See "help Mesh2" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

d=T.Degree;
[t1,t2,v]=getNodes(T,j);
v=v([1,d+1,2*d+1]);
for i=1:3
  if v(i)~=i1 & v(i)~=i2
     i3=v(i);
     break
  end
end
