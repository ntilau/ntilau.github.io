function F = Load(T,fnf,fnk,g,h)

% F = Load(T,fnf,fnk,g,h)
%
%   Assembles the load vector for the BVP
%
%        -div(k*grad u)=f in Omega,
%             u=g on Gamma,
%             k*du/dn=h on Bndy(Omega)-Gamma.
%
%   The forcing function f(x,y) is provided as
%   the input fnf.  If f(x,y) is zero, then fnf
%   can be replaced by the empty matrix [].
%
%   The coefficient k(x,y) is provided as the input
%   fnk, which must be a real-valued function
%   of two variables or a scalar if k(x,y) is constant.
%   The function fnk is not used unless there is an
%   inhomogeneous Dirichlet condition, and so can be
%   omitted (or replaced by []) if there is not.
%
%   The input vector g gives the nodal values at the
%   constrained boundary nodes, in the order they appear
%   in T.CNodePtrs.  If the Dirichlet conditions are
%   homogeneous, then g can be omitted or replaced by [].
%
%   The Nbx2 input array h gives the values of the Neumann
%   data at the boundary nodes of the free edges, in the
%   order they appear in T.FBndyEdges.  If the Neumann
%   conditions are homogeneous, then h can be omitted.
%
%   If T has elements with curved edges, then isoparametric
%   elements are used.
%
%   See "help Mesh" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Handle the optional inputs

if nargin<5
   h=[];
end
if nargin<4
   g=[];
end
if nargin<3|isempty(fnk)
   fnk=1.0;
end
if isnumeric(fnk)
   nkflag=1;
else
   nkflag=0;
end

% Get the number of free nodes and initialize the load vector
% to zero:

Nf = length(T.FNodePtrs);
F = zeros(Nf,1);

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

if ~isempty(fnf) | ~isempty(g)

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

   % Prepare to handle the nonzero right-hand side or Dirichlet
   % data:

   Dflag=(~isempty(g)&any(ll<0));
   if ~isempty(fnf) | Dflag

      % Get the quadrature nodes on T:

      if CurvedEdge
         z=V*coords;
      else
         trans=TransToRefTri(c);
         z=(trans.z1*ones(1,npts)+trans.J*qpts')';
      end

      if CurvedEdge

         % Compute the nonconstant Jacobians and transform
         % the gradients:

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

         % Get the nodal values of the piecewise polynomial function G
         % agreeing with the Dirichlet data at the constrained nodes
         % and having value zero at each free node.

         w=zeros(id,1);
         for j=1:id
            if ll(j)<0
               w(j)=g(-ll(j));
            end
         end

         % Compute the gradients of the function G at the quadrature
         % nodes on T_R:

         Ggrads=zeros(2,npts);
         for ii=1:id
            Ggrads=Ggrads+w(ii)*Grads1(:,:,ii);
         end

      end

   end

   % Handle the nonzero right hand side (if given):

   if ~isempty(fnf)

      % Compute fnf at all the nodes:

      fvals=feval(fnf,z(:,1),z(:,2));

      % Compute the quantities in common with all integrals over T:

      if CurvedEdge
         fhat=scales.*qwts.*fvals;
      else
         fhat=qwts.*fvals;
      end

      % Compute all the integrals by a matrix-vector product:

      I=V'*fhat;
      if ~CurvedEdge
         I=trans.j*I;
      end

      % Loop over all (global) indices related to this triangle.

      for j=1:id

         % Get the indices of the node

         llj=ll(j);
         if llj>0 % (There's nothing to do if this node is not free.)

            % Add add the contribution to the right hand side

            F(llj)=F(llj)+I(j);

         end

      end

   end

   % Now handle the inhomogeneous Dirichlet data, if any:

   if Dflag

      for r=1:id
         llr=ll(r);
         if llr>0

            % Compute the integral:

            I=scale*((Ggrads(1,:).*Grads1(1,:,r)+...
                      Ggrads(2,:).*Grads1(2,:,r))*ghat);
            F(llr)=F(llr)-I;

         end

      end

   end

   % Now handle the inhomogeneous Neumann data, if any

   if ~isempty(h)

      % Loop over the three edges and compute the contribution
      % of each:

      for j=1:3

         % There's nothing to do unless this edge is free:

         eptr=-T.EdgeEls(abs(T.Elements(i,j)),2);
         if eptr>0

            % Interpolate the boundary function at the
            % quadrature nodes:

            hvals=V1*h(eptr,:)';

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

               % Now computes all integrals simultaneously:

               I=0.5*(V1'*(qwts1.*hvals.*ds));

            else

               % Get the endpoints of the edge:

               epts=T.Nodes(ii([1,d+1]),:);

               % Compute the length of the edge:

               len=norm(epts(2,:)-epts(1,:));

               % Now apply the quadrature rule, computing all of the
               % integrals simultaneously

               I=(0.5*len)*(V1'*(qwts1.*hvals));

            end

            % Now add the results to F (notice that the endpoints can
            % be constrained):

            for k=1:d+1

               r=T.NodePtrs(ii(k));
               if r>0
                  F(r)=F(r)+I(k);
               end

            end

         end

      end

   end

end
