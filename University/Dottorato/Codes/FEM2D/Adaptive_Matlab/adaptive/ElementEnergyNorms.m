function m=ElementEnergyNorms(T,Ks,U,g)

% m=ElementEnergyNorms(T,Ks,U,g)
%
%   This routine computes the energy norms, triangle by
%   triangle, of the piecewise polynomial defined by the
%   mesh T and nodal values U (free nodes) and g
%   (constrained nodes).
%
%   Ks is a 3-dimensional array containing the element
%   stiffness matrices; see "help StiffnessE" for details.
%
%   See "help Mesh2" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4 || isempty(g)
   Nc=length(T.CNodePtrs);
   g=zeros(Nc,1);
end

% Get the number of triangles:

Nt=size(T.Elements,1);

% d is the degree of the elements (1=linear, 2=quadratic,etc.).

d=T.Degree;

% id is the number of nodes per triangle.

id=round((d+2)*(d+1)/2);

% Compute the contribution from each element

m=zeros(Nt,1);

for i=1:Nt

   % Get the coordinates and pointers of the nodes:

   [coords,ll]=getNodes(T,i);

   % Extract the values of the piecewise polynomial corresponding
   % to nodes on this triangle:

   U1=zeros(id,1);
   j1=find(ll>0);
   j2=find(ll<0);
   U1(j1)=U(ll(j1));
   U1(j2)=g(-ll(j2));

   % Now compute the norm on this element:

   m(i)=sqrt(U1'*(Ks(:,:,i)*U1));

end
