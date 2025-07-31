function m=LinfNormErr1(T,fnu,U,g)

% m=LinfNormErr1(T,fnu,U,g)
%
%   This function estimates the L-infinity norm of the
%   difference between the smooth function u(x,y) and
%   the piecewise linear function defined by the mesh T
%   and the nodal values U.  The function fnu implements
%   u(x,y).
%
%   The optional input g is a vector containing the nodal
%   values of the piecewise linear function at the
%   constrained nodes.  If g is not given, these values are
%   taken to be zero.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4 | isempty(g)
   g=zeros(size(T.CNodePtrs));
end

% Define the (barycentric coordinates of) the evaluation
% points:

B=[
1 0 0
0 1 0
0 0 1
0.5 0.5 0
0.5 0 0.5
0 0.5 0.5
2/3 1/6 1/6
1/6 2/3 1/6
1/6 1/6 2/3
1/3 1/3 1/3];

% Loop over the triangles in the mesh

m=0;
Nt=size(T.Elements,1);
for k=1:Nt

   % Get the coordinates of the vertices and their indices
   % in FNodePtrs and CNodePtrs:

   [c,ll]=getNodes1(T,k);

   % Record the nodal values of the piecewise linear
   % function.

   u=zeros(3,1);
   for j=1:3
      if ll(j)>0
         u(j)=U(ll(j));
      else
         u(j)=g(-ll(j));
      end
   end

   % Compute the evaluation nodes on this triangle:

   z=B*c;

   % Evaluate the exact function at the evaluation nodes:

   vals=feval(fnu,z(:,1),z(:,2));

   % Evaluate the piecewise linear function at the evaluation
   % nodes:

   uvals=B*u;

   % Choose the maximum difference:

   m=max(m,norm(vals-uvals,inf));

end
