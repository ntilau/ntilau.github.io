function K=StiffnessIso(T,mu,lam)

% K=StiffnessIso(T,mu,lam)
%
%   Assembles the stiffness matrix K for the elliptic PDE
%
%        -div(sigma)=f in Omega,
%                  u=g on Gamma,
%            sigma*n=h on Bndy(Omega)-Gamma,
%   where
%          sigma=2*mu*e(u)+lambda*tr(e(u))*I.
%
%   The Lame' moduli mu and lambda are implemented in the
%   input functions mu and lam, which can be functions of
%   two variables or scalars.  T describes the triangulation
%   of Omega.  If T has elements with curved edges, then
%   isoparametric elements are used.
%
%   See "help Mesh" for a description of the data structure T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Find out if mu and lambda are constants:

if isnumeric(mu)
  nmflag=1;
else
  nmflag=0;
end

if isnumeric(lam)
   nlflag=1;
else
   nlflag=0;
end

% Get the number of free nodes and initialize the matrix K to zero:

Nf=length(T.FNodePtrs);
K=sparse(2*Nf,2*Nf);

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

inodes=getNodes(TR,1);
V=EvalNodalBasisFcns(inodes,qpts);
[Vs,Vt]=EvalNodalBasisGrads(inodes,qpts);

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

   % Compute the values of mu and lam at the quadrature
   % nodes and multiply them by the quadrature weights
   % and Jacobians for convenience:

   if nmflag
      muvals=mu*qwts;
   else
      muvals=qwts.*feval(mu,z(:,1),z(:,2));
   end
   if nlflag
      lamvals=lam*qwts;
   else
      lamvals=qwts.*feval(lam,z(:,1),z(:,2));
   end
   if CurvedEdge
      lamvals=lamvals.*scales;
      muvals=muvals.*scales;
   else
      lamvals=trans.j*lamvals;
      muvals=trans.j*muvals;
   end
   twomulamvals=(2*muvals+lamvals);

   % Compute the contributions to K by looping over all possible
   % combinations of (global) indices related to this triangle.

   for r=1:id
      llr=ll(r);
      if llr>0
         for s=r:id
            lls=ll(s);
            if lls>0

               % These basis functions on this element contribute
               % to four entries in the upper triangle of K
               % (three if ll(r)==ll(s)).

               I1=(Grads1(1,:,r).*Grads1(1,:,s))*twomulamvals+...
                  (Grads1(2,:,r).*Grads1(2,:,s))*muvals;
               I2=(Grads1(1,:,r).*Grads1(1,:,s))*muvals+...
                  (Grads1(2,:,r).*Grads1(2,:,s))*twomulamvals;
               I3=(Grads1(2,:,r).*Grads1(1,:,s))*muvals+...
                  (Grads1(1,:,r).*Grads1(2,:,s))*lamvals;
               if r~=s
                  I4=(Grads1(1,:,r).*Grads1(2,:,s))*muvals+...
                     (Grads1(2,:,r).*Grads1(1,:,s))*lamvals;
               end

               if llr>lls
                  ii=lls;
                  jj=llr;
                  tmp=I3;
                  I3=I4;
                  I4=tmp;
               else
                  ii=llr;
                  jj=lls;
               end
               ii1=ii+Nf;
               jj1=jj+Nf;
               K(ii,jj)=K(ii,jj)+I1;
               K(ii1,jj1)=K(ii1,jj1)+I2;
               K(ii,jj1)=K(ii,jj1)+I3;
               if r~=s
                  K(jj,ii1)=K(jj,ii1)+I4;
               end
            end
         end
      end
   end
end

% Fill in the lower triangle of K, using symmetry:

K=K+triu(K,1)';
