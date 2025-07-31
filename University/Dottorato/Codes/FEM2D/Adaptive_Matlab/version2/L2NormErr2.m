function m=L2NormErr2(T,fnu,U,g,qo)

% m=L2NormErr2(T,fnu,U,g,qo)
%
%   This function computes the L2 norm of the difference
%   between the function u(x,y) and the piecewise
%   polynomial function defined by the mesh T and the
%   nodal values U.  The vector U defines the nodal values
%   at the free nodes; the optional input g defines
%   the nodal values at the constrained nodes.  If g is
%   omitted, it is assumed to be the zero vector.
%
%   qo is the (optional) quadrature order; the default
%   is qo=2*d+2, where d is the degree of the mesh.
%
%   See "help Mesh2" for a description of the data
%   structure T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% d is the degree of the elements (1=linear, 2=quadratic,etc.).

d=T.Degree;

% id is the number of nodes per triangle.

id=round((d+2)*(d+1)/2);

% Handle optional input arguments:

if nargin<5
   qo=2*d+2;
end

if nargin<4 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
end

m=0;

% Create the reference triangle and the quadrature weights and nodes
% on it.

TR=RefTri(d);
[qpts,qwts]=DunavantData(qo);
npts=length(qwts);
inodes=getNodes(TR,1);

% Evaluate the basis functions at the quadrature nodes:

Vals=EvalNodalBasisFcns(inodes,qpts);

% Loop over the triangles in the mesh

Nt=size(T.Elements,1);
for i=1:Nt

   % Get the coordinate of the vertices

   [coords,ll]=getNodes(T,i);
   c=coords(1:d:3*d,1:2);

   % Record the nodal values of the piecewise polynomial:

   u=zeros(id,1);

   for j=1:id
      i1=ll(j);
      if i1>0
         u(j)=U(i1);
      else
         u(j)=g(-i1);
      end
   end

   % Now evaluate the piecewise polynomial at the quadrature nodes:

   Vals1=Vals*u;

   % Transform the triangle to the reference triangle:
   % (The object trans is a struct that describes the
   % transformation (matrix J, etc.).  See TransToRefTri
   % for details.)

   trans=TransToRefTri(c);

   % Compute all the quadrature nodes on T:

   z=(trans.z1*ones(1,npts)+trans.J*qpts')';

   % Compute fnu at all the nodes:

   uvals=feval(fnu,z(:,1),z(:,2));

   % Now add the contribution to the integral

   m=m+trans.j*(qwts'*(Vals1-uvals).^2);

end

m=sqrt(m);
