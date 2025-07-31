function errs=ElementResidual1(T,fnk,fnf,h,U,g,iFlag)

% errs=ElementResidual1(T,fnk,fnf,h,U,g,iFlag)
%
%   This function estimates the errors in (U,g), where
%   (U,g) is the (piecewise linear) finite element
%   solution to the BVP
%
%        -div(k*grad u)=f in Omega,
%             u=g on Gamma,
%             k*du/dn=h on Bndy(Omega)-Gamma
%
%   on the mesh T.  The (implicit) element residual method
%   is used, with three points per element if iFlag is 0
%   and four point if iFlag is 1 (iFlag indicates whether
%   the interior node is used on each element).

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<7
   iFlag=0;
end

if nargin<6 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
end

% Get the values of the bubble functions and their gradients
% at the quadrature nodes.

if iFlag
   prec=4;
else
   prec=2;
end

[qpts,qwts]=DunavantData(prec);
npts=length(qwts);
[Vals,Grads]=getBubbleVals(qpts);

% Get the values of the linear basis functions and their gradients:

Vals1=[1-qpts(:,1)'-qpts(:,2)';qpts(:,1)';qpts(:,2)'];
Grads1=[-1 -1;1 0;0 1]';

% Loop over the elements and estimate the error on each:

Nt=size(T.Elements,1);
errs=zeros(Nt,1);
for i=1:Nt

   errs(i)=ElementResidual1a(T,i,fnk,fnf,h,U,g,Vals,Grads,Vals1,Grads1,...
                           qpts,qwts,iFlag);

end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [v,V]=ElementResidual1a(T,i,fnk,fnf,h,U,g,Vals,Grads,Vals1,...
                                    Grads1,qpts,qwts,iFlag)

% [v,V]=ElementResidual1a(T,i,fnk,fnf,h,U,g,Vals,Grads,Vals1,Grads1,...
%                            qpts,qwts,iFlag)
%
%   This function computes the estimate V of the
%   error in (U,g) on triangle T_i of mesh T.  Here (U,g)
%   is the (piecewise linear) finite element solution to the
%   BVP
%
%        -div(k*grad u)=f in Omega,
%             u=g on Gamma,
%             k*du/dn=h on Bndy(Omega)-Gamma
%
%   on the mesh T.  The output v is the energy norm of the estimated
%   error and V is the vector of nodal values.

if isempty(fnk)
   fnk=1;
end
if isnumeric(fnk)
   nkflag=1;
else
   nkflag=0;
end

% Get the nodes and node pointers for the given triangle:

[c,ll,nn]=getNodes1(T,i);

% Determine which nodes are free:

NodePtrs=zeros(4,1);
FNodePtrs=zeros(0,1);
CNodePtrs=zeros(0,1);
nc=0;
nf=0;
for j=1:3
   if T.EdgeEls(abs(T.Elements(i,j)),2)~=0
      nf=nf+1;
      NodePtrs(j)=nf;
      FNodePtrs=[FNodePtrs;j];
   else
      nc=nc+1;
      NodePtrs(j)=-nc;
      CNodePtrs=[CNodePtrs;j];
   end
end

% The interior node is always free:

if iFlag || nf==0
   nf=nf+1;
   NodePtrs(4)=nf;
   FNodePtrs=[FNodePtrs;4];
else
   NodePtrs=NodePtrs(1:3);
end

% Get the transformation from T_R to T_i:

trans=TransToRefTri(c);

% Get the values of fnk at the quadrature nodes:

npts=length(qwts);
z=trans.z1*ones(1,npts)+trans.J*qpts';
if ~nkflag
   kvals=feval(fnk,z(1,:),z(2,:));
end


% Transform the gradients of the bubble functions to T_i:

Grads2=zeros(2,4,npts);
for j=1:npts
   Grads2(:,:,j)=trans.J'\Grads(:,:,j);
end

% Create the required stiffness matrix:

K=zeros(nf);
for r=1:nf
   for s=r:nf
      tr=reshape(Grads2(:,FNodePtrs(r),:),2,npts);
      ts=reshape(Grads2(:,FNodePtrs(s),:),2,npts);
      if nkflag
         K(r,s)=(fnk*trans.j)*(qwts'*diag(tr'*ts));
      else
         K(r,s)=trans.j*((qwts'.*kvals)*diag(tr'*ts));
      end
   end
end
K=K+triu(K,1)';

% Create the required load vector:

F=zeros(nf,1);

% First, handle the forcing function:

if ~isempty(fnf)

   fvals=feval(fnf,z(1,:),z(2,:));
   for r=1:nf
      I=trans.j*(Vals(FNodePtrs(r),:)*(qwts.*fvals'));
      F(r)=I;
   end

end

% Correct by the piecewise linear function u_h:

% Get the gradient of u_h on this triangle:

uGrad=getGrad1(trans.J,ll,U,g);

% Correct F:

for r=1:nf
   if nkflag
      I=(fnk*trans.j)*(qwts'*...
           (reshape(Grads2(:,FNodePtrs(r),:),2,npts)'*uGrad));
   else
      I=trans.j*((qwts'.*kvals)*...
           (reshape(Grads2(:,FNodePtrs(r),:),2,npts)'*uGrad));
   end
   F(r)=F(r)-I;
end

% Now handle the Neumann data (all the edges are free except those
% that are constrained boundary edges):

% Loop over the edges:

pp=[1;2;3;1];
for l=1:3

   if NodePtrs(l)>0

      % Get the index of the edge:

      e=abs(T.Elements(i,l));

      % Get the index of the triangle across this edge:

      if T.EdgeEls(e,1)==i
         j=T.EdgeEls(e,2);
      else
         j=T.EdgeEls(e,1);
      end

      % Get the length of the edge:

      len=norm(c(pp(l),:)-c(pp(l+1),:));

      % Handle the case that the edge is an interior edge:

      if j>0

         % Get the normal vector:

         n=getNormal1(T,i,l);

         % Get the gradient of u_h on the neighboring triangle:

         [c1,ll1]=getNodes1(T,j);
         trans1=TransToRefTri(c1);
         uGrad1=getGrad1(trans1.J,ll1,U,g);

         % Compute the average normal derivative:

         hval=0.5*((uGrad1+uGrad)'*n);

         % Add the contributions to F:

         % Evaluate the midpoint of the edge:

         mid=0.5*(c(pp(l),:)+c(pp(l+1),:));

         % Evaluate the integral:

         if nkflag
            I=(2/3)*hval*len*fnk;
         else
            I=(2/3)*hval*len*feval(fnk,mid(1),mid(2));
         end

      elseif j<0

         % This is a free boundary edge.  Use the given Neumann data:

         if ~isempty(h)
            I=(len/3)*(h(-j,1)+h(-j,2));
         else
            I=0;
         end

      end

      % Add the contributions to F for bubble function l:

      F(NodePtrs(l))=F(NodePtrs(l))+I;

   end

end

% Compute the nodal values:

V=K\F;
v=sqrt(V'*F);

return
