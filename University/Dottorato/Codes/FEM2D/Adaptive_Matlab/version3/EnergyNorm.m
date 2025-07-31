function m=EnergyNorm(T,fnk,fnvx,fnvy,qo)

% m=EnergyNorm(T,fnk,fnvx,fnvy,qo)
%
%   This function estimates the energy norm of
%   a smooth function u by integrating over the
%   triangles in the mesh T.  Notice that the
%   result might be inaccurate if the mesh is too
%   coarse.
%
%   See "help Mesh" for a description of the mesh T.
%
%   The function fnk is the weight in the energy
%   inner product.  fnk can be a positive scalar
%   or a real-valued function of two variables.
%
%   fnux and fnuy are the partial derivatives of
%   u(x,y).  Each of these functions must be a
%   real-valued function of two real variables.
%
%   qo is the (optional) quadrature order; the
%   default is qo=2*d, where d is the degree of
%   the mesh.
%
%   If T has elements with curved edges, then isoparametric
%   elements are used.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

d=T.Degree;
if nargin<5
   qo=2*(d-1)+2;
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

% Evaluate the the basis functions and their gradients
% at the quadrature nodes:

nodes=getNodes(TR,1);
V=EvalNodalBasisFcns(nodes,qpts);
[Vs,Vt]=EvalNodalBasisGrads(nodes,qpts);

% Loop over the triangles in the mesh

Nt=size(T.Elements,1);
for i=1:Nt

   % Determine whether this triangle has a curved edge
   % (note that by convention, if there is a curved edge, it
   % must be the second edge):

   CurvedEdge=T.EdgeCFlags(abs(T.Elements(i,2))) & d>1;

   % Get the coordinate of the vertices

   [coords,ll]=getNodes(T,i);
   c=coords(1:d:3*d,1:2);

   % Transform the quadrature nodes from the reference
   % triangle to T.  How this is done depends on whether
   % the triangle has a curved edge.

   if CurvedEdge

      % In this case, we not only need to transform the quadrature
      % nodes, but also compute the (nonconstant) Jacobians.

      % Get the quadrature nodes on T:

      z=V*coords;

      % Compute the Jacobians:

      Vsx=Vs*coords(:,1);
      Vsy=Vs*coords(:,2);
      Vtx=Vt*coords(:,1);
      Vty=Vt*coords(:,2);
      scales=zeros(npts,1);
      for ii=1:npts
         J=[Vsx(ii),Vtx(ii);Vsy(ii),Vty(ii)];
         scales(ii)=abs(det(J));
      end

   else

      % A simple affine transformation suffices when no
      % edge is curved:

      trans=TransToRefTri(c);
      z=(trans.z1*ones(1,npts)+trans.J*qpts')';

   end

   % Compute fnk, fnvx, and fnvy at all the nodes:

   if ~nkflag
      kvals=feval(fnk,z(:,1),z(:,2));
   end
   vxvals=feval(fnvx,z(:,1),z(:,2));
   vyvals=feval(fnvy,z(:,1),z(:,2));

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
      I=fnk*sum(ghat.*(vxvals.^2+vyvals.^2));
   elseif CurvedEdge
      I=sum(ghat.*(vxvals.^2+vyvals.^2));
   elseif nkflag
      I=scale*sum(qwts.*(vxvals.^2+vyvals.^2));
   else
      I=trans.j*sum(ghat.*(vxvals.^2+vyvals.^2));
   end

   m=m+I;

end

m=sqrt(m);

