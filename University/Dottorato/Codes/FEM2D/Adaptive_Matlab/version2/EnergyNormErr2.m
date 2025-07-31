function m=EnergyNormErr2(T,fnk,fnux,fnuy,U,g,qo)

% m=EnergyNormErr2(T,fnk,fnux,fnuy,U,g,qo)
%
%   This function estimates the energy norm of the
%   difference between the function u(x,y) and the
%   piecewise polynomial function defined by the mesh
%   T and the nodal values U.  The vector U defines the
%   nodal values at the free nodes; the optional input
%   g defines the nodal values at the constrained nodes.
%   If g is omitted, it is assumed to be the zero vector.
%
%   The function fnk is the weight in the energy inner
%   product, while fnux and fnuy are the partial derivatives
%   of u(x,y).  fnux and fnuy must be real-valued functions
%   of two variables, while fnk can be a positive scalar or
%   a function.
%
%   qo is the (optional) quadrature order; the default is
%   qo=2*d, where d is the degree of the mesh.
%
%   See "help Mesh2" for a description of the data
%   structure T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% d is the degree of the elements (1=linear, 2=quadratic,etc.).

d=T.Degree;

if nargin<7
   qo=2*d;
end

if nargin<6 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
end

if isempty(fnk)
   fnk=1.0;
end
if isnumeric(fnk)
   nkflag=1;
else
   nkflag=0;
end

m=0;

% id is the number of nodes per triangle.

id=round((d+2)*(d+1)/2);

% Create the reference triangle and the quadrature weights and nodes
% on it.

TR=RefTri(d);
[qpts,qwts]=DunavantData(qo);
npts=length(qwts);

% Evaluate the gradients of all the basis functions at all
% of the quadrature nodes:

[Vs,Vt]=EvalNodalBasisGrads(getNodes(TR,1),qpts);

% Loop over the triangles in the mesh

Nt=size(T.Elements,1);
for i=1:Nt

   % Get the coordinate of the vertices

   [coords,ll]=getNodes(T,i);
   c=coords(1:d:3*d,1:2);

   % Record the nodal values of u(x,y)

   u=zeros(id,1);

   for j=1:id
      i1=ll(j);
      if i1>0
         u(j)=U(i1);
      else
         u(j)=g(-i1);
      end
   end

   % Transform the triangle to the reference triangle:
   % (The object trans is a struct that describes the
   % transformation (matrix J, etc.).  See TransToRefTri
   % for details.)

   trans=TransToRefTri(c);

   % Compute all the quadrature nodes on T:

   z=trans.z1*ones(1,npts)+trans.J*qpts';

   % Compute fnk, fnux, and fnuy at all the nodes:

   if nkflag
      kvals=fnk;
   else
      kvals=feval(fnk,z(1,:),z(2,:));
   end
   ugrads=[feval(fnux,z(1,:),z(2,:));
           feval(fnuy,z(1,:),z(2,:))];

   % Get the gradients of the polynomial at the quadrature
   % nodes on T:

   pGrads=zeros(2,npts);
   for j=1:id
      pGrads=pGrads+u(j)*(trans.J'\[Vs(:,j)';Vt(:,j)']);
   end

   % Now add the contribution to the integral

   gradsdot=((ugrads(1,:)-pGrads(1,:)).^2+(ugrads(2,:)-pGrads(2,:)).^2)';
   if nkflag
      I=(kvals*trans.j)*(qwts'*gradsdot);
   else
      I=trans.j*((qwts'.*kvals)*gradsdot);
   end
   m=m+I;

end

m=sqrt(m);

