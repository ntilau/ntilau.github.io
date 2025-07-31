function d=getDiameters(T,list)

% d=getDiameters(T,list)
%
%   This function computes the diameters of the
%   triangles in the mesh T indexed by list, and
%   returns them in the array d.  If the optional
%   input list is not provided, it is taken to be
%   1:Nt, where Nt is the number of triangles in
%   the mesh.
%
%   See "help Mesh2" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

Nt=size(T.Elements,1);
if nargin<2
   list=1:Nt;
end
n=length(list);

d=zeros(n,1);
for i=1:n
   d(i)=getDiameter(T,list(i));
end


