function [m,elerrs]=EnergyNormErr(T,fnk,fnvx,fnvy,U,g,qo)

% m=EnergyNormErr(T,fnk,fnvx,fnvy,U,g,qo)
%
%   This function estimates the energy norm of the
%   difference between the function v(x,y) and the
%   piecewise polynomial function defined by the mesh
%   T and the nodal values U (free nodes) and g
%   (constrained nodes).  If g is omitted, it is
%   assumed to be the zero vector.
%
%   The input fnk is the weight in the energy inner
%   product, while fnvx and fnvy are the partial
%   derivatives of v(x,y).  fnvx and fnvy must be
%   real-valued functions of two real variables,
%   while fnk can be a positive scalar or a function.
%
%   qo is the (optional) quadrature order; the default
%   is qo=2*d, where d is the degree of the mesh.
%
%   If T has elements with curved edges, then isoparametric
%   elements are used.
%
%   See "help Mesh" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% d is the degree of the elements (1=linear, 2=quadratic,etc.):

d=T.Degree;

% Handle optional arguments:

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

% id is the number of nodes per triangle.

id=round((d+2)*(d+1)/2);

% Create the reference triangle and the quadrature weights and nodes
% on it.

TR=RefTri(d);
[qpts,qwts]=DunavantData(qo);
npts=length(qwts);

% Evaluate the the basis functions and their gradients
% at the quadrature nodes:

nodes=getNodes(TR,1);
V=EvalNodalBasisFcns(nodes,qpts);
[Vs,Vt]=EvalNodalBasisGrads(nodes,qpts);

% Add the contributions from each element

Nt=size(T.Elements,1);
m=0;
if nargout>1
   elerrs=zeros(Nt,1);
end
for i=1:Nt

   % Determine whether this triangle has a curved edge
   % (note that by convention, if there is a curved edge, it
   % must be the second edge):

   CurvedEdge=T.EdgeCFlags(abs(T.Elements(i,2))) & d>1;

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

   % Transform the reference triangle to T.  How this is
   % done depends on whether the triangle has a curved
   % edge.

   if CurvedEdge

      % In this case, we not only need to transform the quadrature
      % nodes, but compute the (nonconstant) Jacobians and
      % transform the gradients:

      % Get the quadrature nodes on T:

      z=V*coords;

      % Compute the Jacobians and transform the gradients:

      Vsx=Vs*coords(:,1);
      Vsy=Vs*coords(:,2);
      Vtx=Vt*coords(:,1);
      Vty=Vt*coords(:,2);
      Grads1=zeros(2,npts,id);
      scales=zeros(npts,1);
      for ii=1:npts
         J=[Vsx(ii),Vtx(ii);Vsy(ii),Vty(ii)];
         Grads1(:,ii,:)=J'\[Vs(ii,:);Vt(ii,:)];
         scales(ii)=abs(det(J));
      end

   else

      % A simple affine transformation suffices when no
      % edge is curved:

      trans=TransToRefTri(c);
      z=(trans.z1*ones(1,npts)+trans.J*qpts')';

      Grads1=zeros(2,npts,id);
      for ii=1:npts
          Grads1(:,ii,:)=trans.J'\[Vs(ii,:);Vt(ii,:)];
      end

   end

   if ~nkflag
      kvals=feval(fnk,z(:,1),z(:,2));
   end
   vxvals=feval(fnvx,z(:,1),z(:,2));
   vyvals=feval(fnvy,z(:,1),z(:,2));

   % Get the gradients of the polynomial at the quadrature
   % nodes:

   pGrads=zeros(2,npts);
   for j=1:id
      pGrads=pGrads+u(j)*Grads1(:,:,j);
   end

   % Compute the quantities in common to all integrals over T:

   if CurvedEdge&nkflag
      ghat=scales.*qwts;
   elseif CurvedEdge
      ghat=scales.*qwts.*kvals;
   elseif nkflag
      scale=fnk*trans.j;
   else
      ghat=qwts.*kvals;
   end

   % Now add the contribution to the integral

   if CurvedEdge&nkflag
      I=fnk*sum(ghat.*((vxvals-pGrads(1,:)').^2+(vyvals-pGrads(2,:)').^2));
   elseif CurvedEdge
      I=sum(ghat.*((vxvals-pGrads(1,:)').^2+(vyvals-pGrads(2,:)').^2));
   elseif nkflag
      I=scale*sum(qwts.*((vxvals-pGrads(1,:)').^2+(vyvals-pGrads(2,:)').^2));
   else
      I=trans.j*sum(ghat.*((vxvals-pGrads(1,:)').^2+(vyvals-pGrads(2,:)').^2));
   end

   m=m+I;
   if nargout>1
      elerrs(i)=I;
   end
end

m=sqrt(m);
if nargout>1
   elerrs=sqrt(elerrs);
end

