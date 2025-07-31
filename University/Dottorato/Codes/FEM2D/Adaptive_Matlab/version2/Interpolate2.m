function [U1,g1]=Interpolate2(T,T1,U,g)

% [U1,g1]=Interpolate2(T,T1,U,g)
%
%   This function interpolates the piecewise linear
%   function U, defined on mesh T, on the mesh T1 of
%   degree d.  T1 must be obtained from T by an
%   application of GenLagrangeMesh2.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
end

% The first mesh must be linear and the second higher degree:

if T.Degree~=1
   error('Original mesh must consist of linear Lagrange triangles')
end

d=T1.Degree;
if d==1
   error('Target mesh must have degree greater than 1')
end

if size(T1.Elements,1)~=size(T.Elements,1)
   error('T1 must be obtained from T by GenLagrangeMesh2')
end

% Assign the nodal values from T to V:

Nv1=length(T1.NodePtrs);
U1=zeros(Nv1,1);
U1(T.FNodePtrs)=U;
U1(T.CNodePtrs)=g;

% Next, handle the edge nodes:

A=[(d-1:-1:1)/d;(1:d-1)/d]';
Ne=size(T1.Edges,1);
for i=1:Ne

   % Extract the values at the endpoints:

   v=U1(T1.Edges(i,[1,d+1]));
 
   % Interpolate:

   U1(T1.Edges(i,2:d))=A*v;

end

% Now handle the interior nodes:

if d>2

   id=(d+1)*(d+2)/2;
   B=zeros(id-3*d,3);
   r=0;
   for i=1:d-2
      for j=1:d-i-1
         k=d-i-j;
         r=r+1;
         B(r,:)=[k/d,j/d,i/d];
      end
   end

   Nt=size(T.Elements,1);
   for i=1:Nt

      % Extract the values of the vertices:

      [coords,ptrs,ii]=getVertices(T,i);
      v=U1(ii);

      % Interpolate:

      U1(T1.IntNodes(i,:))=B*v;

   end

end

% Finally, extract the nodal values:

if nargout>1
   g1=U1(T1.CNodePtrs);
end
U1=U1(T1.FNodePtrs);
