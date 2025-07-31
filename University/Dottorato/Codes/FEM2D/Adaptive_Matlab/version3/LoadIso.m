function F = LoadIso(T,fnf1,fnf2,mu,lam,g,h)

% F = LoadIso(T,fnf1,fnf2,mu,lam,g,h)
%
%   Assembles the load vector for the BVP
%
%        -div(sigma)=f in Omega,
%                  u=g on Gamma,
%            sigma*n=h on Bndy(Omega)-Gamma,
%   where
%          sigma=2*mu*e(u)+lambda*tr(e(u))*I.
%
%   The right-hand-side function f(x,y), which is
%   vector-valued, is implemented in the functions fnf1,
%   fnf2.  If the forcing function is zero, then [] (the
%   empty vector) can be given in place of fnf1, fnf2.
%
%   The 2*Nc by 1 array g must contain the Dirichlet
%   data for the nodes on Gamma.  The first Nc components
%   contain the values of the first component function at
%   the constrained nodes, in the order they appear in
%   T.CNodePtrs, and the next Nc components contain the
%   same for the second component function.  The inputs
%   mu and lam are the Lame' moduli; they can be scalars
%   or functions and are needed only if g is nonzero.
%   If the Dirichlet conditions are homogeneous (or there
%   are none), then mu, lam, and g can be replaced by [].
%
%   The 2 by (d+1) by Nb array h must give the values of
%   the Neumann data at the the boundary nodes on the free
%   edges, in the order they appear in T.FBndyEdges.  Here d
%   is the degree of the elements.  If the Neumann conditions
%   are homogeneous, then h can be omitted.
%
%   See "help Mesh" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Handle the optional inputs

if nargin<7
   h=[];
end
if nargin<6
   g=[];
else
   nmflag=0;
   nlflag=0;
   if isnumeric(mu)
      nmflag=1;
   end
   if isnumeric(lam)
      nlflag=1;
   end
end

% Get the number of free nodes and initialize the load vector
% to zero:

Nf=length(T.FNodePtrs);
Nc=length(T.CNodePtrs);
F=zeros(2*Nf,1);

% Get the number of triangles:

Nt=size(T.Elements,1);

% d is the degree of the elements (1=linear, 2=quadratic,etc.).

d=T.Degree;

% id is the number of nodes per triangle.

id=round((d+2)*(d+1)/2);

% The following quadrature weights, nodes, etc. are needed only
% if the right-hand side is nonzero or there is nonzero
% Dirichlet data:

% Extract the interpolation nodes from the reference triangle:

TR=RefTri(d);
inodes=getNodes(TR,1);

if ~isempty(fnf1) | ~isempty(g)

   % Create the quadrature weights and nodes on the reference
   % triangle.

   [qpts,qwts]=DunavantData(2*d-2);
   npts=length(qwts);

   % Evaluate all the basis functions and their gradients at all
   % of the quadrature nodes:

   V=EvalNodalBasisFcns(inodes,qpts);
   [Vs,Vt]=EvalNodalBasisGrads(inodes,qpts);

end

% Prepare to handle the inhomogeneous Neumann data, if any:

if ~isempty(h)

   % Get the quadrature weights and nodes on the reference
   % interval [-1,1]:

   [qpts1,qwts1]=GaussData(2*d);

   % Get the interpolation nodes on the reference interval:

   t=linspace(-1,1,d+1)';

   % Evaluate all of the basis functions at the quadrature nodes:

   V1=EvalNodalBasisFcns1D(t,qpts1);

   % Evaluate the gradients of the basis functions at the
   % boundary quadrature nodes:

   s=0.5*(qpts1+1);
   enodes=[1-s,s];
   [Vs1,Vt1]=EvalNodalBasisGrads(inodes,enodes);

end

% Add the contributions from each element

for i=1:Nt

   % Determine whether this triangle has a curved edge
   % (note that by convention, if there is a curved edge, it
   % must be the second edge).  If the triangles are linear,
   % then the edge is straight by default.

   CurvedEdge=T.EdgeCFlags(abs(T.Elements(i,2))) & d>1;

   % Get the coordinates and pointers of the nodes:

   [coords,ll]=getNodes(T,i);

   % Extract the coordinates of the vertices of the triangle:

   c=coords(1:d:2*d+1,1:2);

   % Prepare to handle the nonzero right-hand side or nonzero
   % Dirichlet data:

   Dflag=(~isempty(g)&any(ll<0));
   if ~isempty(fnf1) | Dflag

      % Get the quadrature nodes on T:

      if CurvedEdge
         z=V*coords;
      else
         trans=TransToRefTri(c);
         z=(trans.z1*ones(1,npts)+trans.J*qpts')';
      end

      if CurvedEdge

         % Compute the nonconstant Jacobians:

         Vsx=Vs*coords(:,1);
         Vsy=Vs*coords(:,2);
         Vtx=Vt*coords(:,1);
         Vty=Vt*coords(:,2);
         Grads1=zeros(2,npts,id);
         scales=zeros(npts,1);
         for ii=1:npts
            J=[Vsx(ii),Vtx(ii);Vsy(ii),Vty(ii)];
            scales(ii)=abs(det(J));
            if Dflag
               Grads1(:,ii,:)=J'\[Vs(ii,:);Vt(ii,:)];
            end
         end

      elseif Dflag

         Grads1=zeros(2,npts,id);
         for ii=1:id
            Grads1(:,:,ii)=trans.J'\[Vs(:,ii)';Vt(:,ii)'];
         end

      end

      % Prepare to handle inhomogeneous Dirichlet condition:

      if Dflag

         % Compute fnk at all the nodes:

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

         % Get the nodal values of the piecewise polynomial function G
         % agreeing with the Dirichlet data at the constrained nodes
         % and having value zero at each free node.

         w1=zeros(id,1);
         w2=zeros(id,1);
         ii=find(ll<0);
         w1(ii)=g(-ll(ii));
         w2(ii)=g(Nc-ll(ii));

         % Compute the gradients of the function G at the quadrature
         % nodes on T_R:

         G1grads=zeros(2,npts);
         G2grads=zeros(2,npts);
         for ii=1:id
            G1grads=G1grads+w1(ii)*Grads1(:,:,ii);
            G2grads=G2grads+w2(ii)*Grads1(:,:,ii);
         end

      end

      if ~isempty(fnf1)

         % Compute fnf at all the nodes:

         f1vals=feval(fnf1,z(:,1),z(:,2));
         f2vals=feval(fnf2,z(:,1),z(:,2));

         % Compute the quantities in common with all integrals over T:

         if CurvedEdge
            tmp=scales.*qwts;
            f1hat=tmp.*f1vals;
            f2hat=tmp.*f2vals;
         else
            f1hat=qwts.*f1vals;
            f2hat=qwts.*f2vals;
         end

      end

   end

   % Now compute the contributions of the function f:

   if ~isempty(fnf1)

      % Compute all the integrals by a matrix-vector product:

      I1=V'*f1hat;
      I2=V'*f2hat;
      if ~CurvedEdge
         I1=trans.j*I1;
         I2=trans.j*I2;
      end

      % Loop over all (global) indices related to this triangle.

      for j=1:id

         % Get the indices of the node

         llj=ll(j);
         if llj>0 % (There's nothing to do if this node is not free.)

            % Add add the contribution to the right hand side

            F(llj)=F(llj)+I1(j);
            F(llj+Nf)=F(llj+Nf)+I2(j);

         end

      end

   end

   % Compute the contributions of the Dirichlet data:

   if Dflag

      for r=1:id
         llr=ll(r);
         if llr>0

            % Compute the integrals:

            I1=(G1grads(1,:).*Grads1(1,:,r))*twomulamvals+...
               ((G1grads(2,:)+G2grads(1,:)).*Grads1(2,:,r))*muvals+...
               (G2grads(2,:).*Grads1(1,:,r))*lamvals;
            I2=(G2grads(2,:).*Grads1(2,:,r))*twomulamvals+...
               ((G1grads(2,:)+G2grads(1,:)).*Grads1(1,:,r))*muvals+...
               (G1grads(1,:).*Grads1(2,:,r))*lamvals;
            F(llr)=F(llr)-I1;
            F(Nf+llr)=F(Nf+llr)-I2;

         end

      end

   end

   % Finally, handle the inhomogeneous Neumann data:

   if ~isempty(h)

      % Loop over the three edges and compute the contribution
      % of each:

      for j=1:3

         % There's nothing to do unless this edge is free:

         eptr=-T.EdgeEls(abs(T.Elements(i,j)),2);
         if eptr>0

            % Evaluate the boundary function at the quadrature nodes:

            h1vals=V1*h(1,:,eptr)';
            h2vals=V1*h(2,:,eptr)';

            ii=T.Edges(abs(T.Elements(i,j)),:);

            % Compute all the needed integrals simultaneously,
            % using an appropriate quadrature rule:

            if CurvedEdge

               % The curve e is given by
               %       (p(1-s,s),q(1-s,s)), 0<=s<=1,
               % where p and q are polynomials of degree d.

               % First, compute the elements of arc length
               % at the quadrature nodes:

               tv=[(Vt1*coords(:,1)-Vs1*coords(:,1))';
                   (Vt1*coords(:,2)-Vs1*coords(:,2))'];

               ds=sqrt(tv(1,:).^2+tv(2,:).^2)';

               % Now compute all integrals simultaneously:

               I1=0.5*(V1'*(qwts1.*h1vals.*ds));
               I2=0.5*(V1'*(qwts1.*h2vals.*ds));

            else

               % Get the endpoints of the edge:

               epts=T.Nodes(ii([1,d+1]),:);

               % Compute the length of the edge:

               len=norm(epts(2,:)-epts(1,:));

               % Now compute all integrals simultaneously

               I1=(0.5*len)*(V1'*(qwts1.*h1vals));
               I2=(0.5*len)*(V1'*(qwts1.*h2vals));

            end

            % Add the results to F (notice that the endpoints can
            % be constrained):

            for k=1:d+1

               r=T.NodePtrs(ii(k));
               if r>0
                  F(r)=F(r)+I1(k);
                  F(r+Nf)=F(r+Nf)+I2(k);
               end

            end

         end

      end

   end

end
