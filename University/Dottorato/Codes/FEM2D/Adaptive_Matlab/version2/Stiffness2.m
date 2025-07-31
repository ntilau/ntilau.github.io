function K=Stiffness2(T,fnk)

% K=Stiffness2(T,fnk)
%
%   Assembles the stiffness matrix for the elliptic PDE
%
%        -div(k*grad u)=f in Omega,
%             u=g on Gamma,
%             k*du/dn=h on Bndy(Omega)-Gamma.
%
%   The coefficient k(x,y) must be implemented in the
%   function fnk; if k is constant, then fnk can be a
%   positive scalar.  If fnk is omitted, k is taken to be
%   the constant 1.  T describes the triangulation of Omega.
%
%   See "help Mesh2" for a description of the data structure T.

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

% Evaluate the gradients of all the basis functions at all
% of the quadrature nodes:

[Vs,Vt]=EvalNodalBasisGrads(getNodes(TR,1),qpts);

% Add the contributions from each element

for i=1:Nt

   % Get the coordinates and pointers of the nodes:

   [coords,ll]=getNodes(T,i);

   % Extract the coordinates of the vertices of the triangle:

   c=coords(1:d:2*d+1,1:2);

   % Transform the triangle to the reference triangle:
   % (The object trans is a struct that describes the
   % transformation (matrix J, etc.).  See TransToRefTri
   % for details.)

   trans=TransToRefTri(c);

   % Transform the gradients to the reference triangle:

   Grads1=zeros(2,npts,id);
   for ii=1:id
      Grads1(:,:,ii)=trans.J'\[Vs(:,ii)';Vt(:,ii)'];
   end

   % Compute all the quadrature nodes on T:

   z=trans.z1*ones(1,npts)+trans.J*qpts';

   % Compute quantities common to the integrals:

   if nkflag
      scale=fnk*trans.j;
      ghat=qwts;
   else
      scale=trans.j;
      ghat=feval(fnk,z(1,:)',z(2,:)').*qwts;
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

% Fill in the lower triangle of K.

K=K + triu(K,1)';
