function m=ElementEnergyNormErrs1(T,fnk,fnvx,fnvy,U,g)

% m=ElementEnergyNormErrs1(T,fnk,fnvx,fnvy,U,g)
%
%   This function computes, triangle by triangle,
%   the energy norm of the difference between the
%   function v(x,y) and the piecewise polynomial
%   function defined by the mesh T and the nodal
%   values U.  The vector U defines the nodal values
%   at the free nodes; the optional input g defines
%   the nodal values at the constrained nodes.  If
%   g is omitted, it is assumed to be the zero vector.
%
%   The function fnk is the weight in the energy inner
%   product, and can be a positive scalar or a function
%   of two variables.  fnvx and fnvy are the partial
%   derivatives of v(x,y) and must be functions of two
%   variables.
%
%   The output is an Nt by 1 array, where Nt is the
%   number of triangles.
%
%   See "help Mesh" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<6 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
end

if isempty(fnk)
   fnk=1;
end
if isnumeric(fnk)
   nkflag=1;
else
   nkflag=0;
end

Nt=size(T.Elements,1);
m=zeros(Nt,1);

% d is the degree of the elements (1=linear, 2=quadratic,etc.).

d=T.Degree;

% id is the number of nodes per triangle.

id=round((d+2)*(d+1)/2);

% Create the reference triangle and the quadrature weights and nodes
% on it.

%TR=RefTri2(d);
TR=RefTri(d);
[qpts,qwts]=DunavantData(2*d);
npts=length(qwts);

% Evaluate the gradients of all the basis functions at all
% of the quadrature nodes:

[Vs,Vt]=EvalNodalBasisGrads(getNodes(TR,1),qpts);

% Loop over the triangles in the mesh

for i=1:Nt

   % Get the coordinate of the vertices

   [coords,ll]=getNodes(T,i);
   c=coords(1:d:3*d,1:2);

   % Record the nodal values of u(x,y)

   u=zeros(id,1);
   j1=find(ll>0);
   j2=find(ll<0);
   u(j1)=U(ll(j1));
   u(j2)=g(-ll(j2));

   % Transform the triangle to the reference triangle:
   % (The object trans is a struct that describes the
   % transformation (matrix J, etc.).  See TransToRefTri
   % for details.)

   trans=TransToRefTri(c);

   % Compute all the quadrature nodes on T:

   z=trans.z1*ones(1,npts)+trans.J*qpts';

   % Compute fnk, fnvx, and fnvy at all the nodes:

   if ~nkflag
      kvals=feval(fnk,z(1,:)',z(2,:)');
   end
   vxvals=feval(fnvx,z(1,:)',z(2,:)');
   vyvals=feval(fnvy,z(1,:)',z(2,:)');

   % Get the gradients of the polynomial at the quadrature
   % nodes on the reference triangle:

   pGrads=trans.J'\[(Vs*u)';(Vt*u)'];

   % Now compute the error:

   gradsdot=((vxvals-pGrads(1,:)').^2+(vyvals-pGrads(2,:)').^2);
   if nkflag
      m(i)=(fnk*trans.j)*(qwts'*gradsdot);
   else
      m(i)=trans.j*((qwts.*kvals)'*gradsdot);
   end

end

m=sqrt(m);

