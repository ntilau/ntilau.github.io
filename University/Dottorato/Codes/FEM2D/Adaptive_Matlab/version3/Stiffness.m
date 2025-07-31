function K=Stiffness(T,fnk)

% K=Stiffness(T,fnk)
%
%   Assembles the stiffness matrix for the elliptic PDE
%
%        -div(k*grad u)=f in Omega,
%             u=g on Gamma,
%             k*du/dn=h on Bndy(Omega)-Gamma.
%
%   The coefficient k(x,y) is defined by the input fnk.
%   If k is constant, fnk can be a positive scalar.
%   If fnk is omitted, k is taken to be the constant
%   function 1.  Otherwise, fnk must be a function of
%   two variables.
%
%   T describes the triangulation of Omega. If T has
%   elements with curved edges, then isoparametric
%   elements are used.
%
%   See "help Mesh" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<2 | isempty(fnk)
   fnk=1.0;
end
if isnumeric(fnk)
   nkflag=1;
else
   nkflag=0;
end

% Get the number of free nodes and initialize the stiffness
% matrix to zero:

Nf=length(T.FNodePtrs);
K=sparse(Nf,Nf);

% Get the number of triangles:

Nt=size(T.Elements,1);

% d is the degree of the elements (1=linear, 2=quadratic,etc.).

d=T.Degree;

% id is the number of nodes per triangle.

id=round((d+2)*(d+1)/2);

% Create the reference triangle and the quadrature weights and nodes
% on it.

TR=RefTri(d);
[qpts,qwts]=DunavantData(2*d-2);
npts=length(qwts);

% Evaluate the values and gradients of all the basis functions
% at all of the quadrature nodes:

nodes=getNodes(TR,1);
V=EvalNodalBasisFcns(nodes,qpts);
[Vs,Vt]=EvalNodalBasisGrads(nodes,qpts);

% Add the contributions from each element

for i=1:Nt

   % Determine whether this triangle has a curved edge
   % (note that by convention, if there is a curved edge, it
   % must be the second edge):

   CurvedEdge=T.EdgeCFlags(abs(T.Elements(i,2))) & d>1;

   % Get the coordinates and pointers of the nodes:

   [coords,ll]=getNodes(T,i);

   % Extract the coordinates of the vertices of the triangle:

   c=coords(1:d:2*d+1,1:2);

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

   % Compute fnk at all the nodes:

   if ~nkflag
      kvals=feval(fnk,z(:,1),z(:,2));
   end

   % Compute the quantities in common to all integrals over T:

   if CurvedEdge&nkflag
      scale=fnk;
      ghat=scales.*qwts;
   elseif CurvedEdge
      scale=1.0;
      ghat=scales.*qwts.*kvals;
   elseif nkflag
      scale=fnk*trans.j;
      ghat=qwts;
   else
      scale=trans.j;
      ghat=qwts.*kvals;
   end

   % Loop over all possible combinations of (global) indices related
   % to this triangle.

   for r=1:id
      llr=ll(r);
      if llr>0

         for s=r:id
            lls=ll(s);
            if lls>0 

               % Estimate the integral:

               I=scale*((Grads1(1,:,r).*Grads1(1,:,s)+...
                         Grads1(2,:,r).*Grads1(2,:,s))*ghat);

               ii=min(llr,lls);
               jj=max(llr,lls);
               K(ii,jj)=K(ii,jj)+I;

            end

         end

      end

   end

end

% Fill in the lower triangle of K, using symmetry.

K=K+triu(K,1)';
