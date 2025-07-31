function m=EnergyNorm2(T,fnk,fnux,fnuy,qo)

% m=EnergyNorm2(T,fnk,fnux,fnuy,qo)
%
%   This function estimates the energy norm of a smooth
%   function u by integrating over the triangles in the
%   mesh T.   Notice that the result might be inaccurate
%   if the mesh is too coarse.
%
%   The function fnk is the weight in the energy inner product;
%   it must be a function of two variables or a positive
%   constant.
%
%   fnux and fnuy are the partial derivatives of u(x,y).
%   These inputs must be real-valued functions of
%   two real variables.
%
%   qo is the (optional) quadrature order; the default is
%   qo=2*d, where d is the degree of the mesh.
%
%   See "help Mesh2" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

d=T.Degree;
if nargin<5
   qo=2*d;
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

% Create the reference triangle and the quadrature weights and nodes
% on it.

TR=RefTri(d);
[qpts,qwts]=DunavantData(qo);
npts=length(qwts);

% Loop over the triangles in the mesh

Nt=size(T.Elements,1);
for i=1:Nt

   % Get the coordinate of the vertices

   [coords,ll]=getNodes(T,i);
   c=coords(1:d:3*d,1:2);

   % Transform the triangle to the reference triangle:
   % (The object TransRef is a struct that describes the
   % transformation (matrix J, etc.).  See TransToRefTri
   % for details.)

   trans=TransToRefTri(c);

   % Compute all the quadrature nodes on T:

   z=trans.z1*ones(1,npts)+trans.J*qpts';

   % Compute fnk, fnux, and fnuy at all the nodes:

   if nkflag
      kvals=fnk;
   else
      kvals=feval(fnk,z(1,:)',z(2,:)');
   end
   ugrads=[feval(fnux,z(1,:),z(2,:));feval(fnuy,z(1,:),z(2,:))];

   % Now add the contribution to the integral

   if nkflag
      I=(kvals*trans.j)*sum(qwts.*((ugrads(1,:)').^2+(ugrads(2,:)').^2));
   else
      I=trans.j*sum(qwts.*kvals.*((ugrads(1,:)').^2+(ugrads(2,:)').^2));
   end
   m=m+I;

end

m=sqrt(m);

