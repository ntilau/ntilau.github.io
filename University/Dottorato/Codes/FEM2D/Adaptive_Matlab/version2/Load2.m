function F = Load2(T,fnf,fnk,g,h)

% F = Load2(T,fnf,fnk,g,h)
%
%   Assembles the load vector for the BVP
%
%        -div(k*grad u)=f in Omega,
%             u=g on Gamma,
%             k*du/dn=h on Bndy(Omega)-Gamma.
%
%   The right-hand-side function f(x,y) must be implemented
%   in the function fnf.  If the forcing function is zero,
%   then [] (the empty vector) can be given in place of fnf.
%
%   The coefficient k(x,y) must be implemented in the
%   function fnk, which must be a real-valued function
%   of two variables, or a positive constant.  If fnk is
%   omitted, it is taken to be the constant 1.
%
%   The function fnk is not used unless there is an
%   inhomogeneous Dirichlet condition, and so can be
%   omitted (or replaced by []) if there is not.
%
%   The vector g must give the nodal values at the
%   constrained boundary nodes, in the order they appear
%   in T.CNodePtrs.  If the Dirichlet conditions are
%   homogeneous, then g can be omitted or replaced by [].
%
%   The Nb by (d+1) array h must give the values of the
%   Neumann data at the the boundary nodes on the free
%   edges, in the order they appear in T.FBndyEdges.  Here
%   d is the degree of the elements.  If the Neumann
%   conditions are homogeneous, then h can be omitted.
%
%   See "help Mesh2" for a description of the data
%   structure T.

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
if nargin<3
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
% if the right-hand side is nonzero or there is nonzero Dirichlet data:

if ~isempty(fnf) | ~isempty(g)

   % Create the reference triangle and the quadrature weights and nodes
   % on it.

   TR=RefTri(d);
   [qpts,qwts]=DunavantData(2*d-2);
   npts=length(qwts);

   % Extract the interpolation nodes from the reference triangle:

   inodes=getNodes(TR,1);

end

% If the right-hand side of the PDE is nonzero, evaluate all
% the basis functions at all of the quadrature nodes:

if ~isempty(fnf)
   V=EvalNodalBasisFcns(inodes,qpts);
end

% If there is inhomogeneous Dirichlet data, record the
% gradients of the basis functions at all of the quadrature nodes.

if ~isempty(g)
   [Vs,Vt]=EvalNodalBasisGrads(inodes,qpts);
end

% Prepare to handle the inhomogeneous Neumann data, if any:

if ~isempty(h)

   % Get the quadrature weights and nodes on the reference
   % interval [0,1]:

   [qpts1,qwts1]=GaussData(2*d);

   % Get the interpolation nodes on the reference interval:

   t=linspace(-1,1,d+1)';

   % Evaluate all of the basis functions at the quadrature nodes:

   V1=EvalNodalBasisFcns1D(t,qpts1);

end

% Add the contributions from each element

for i=1:Nt

   % Get the coordinates and pointers of the nodes:

   [coords,ll]=getNodes(T,i);

   % Extract the coordinates of the vertices of the triangle:

   c=coords(1:d:2*d+1,1:2);

   % Prepare to handle the nonzero right hand side
   % or nonzero Dirichlet data:

   if ~isempty(fnf) | (~isempty(g) & any(ll<0))

      % Transform the triangle to the reference triangle:
      % (The object trans is a struct that describes the
      % transformation (matrix J, etc.).  See TransToRefTri
      % for details.)

      trans=TransToRefTri(c);

      % Compute all the quadrature nodes on T:

      z=trans.z1*ones(1,npts)+trans.J*qpts';

   end

   % Handle the nonzero right-hand side (if given):

   if ~isempty(fnf)

      % Compute fnf at all the nodes:

      fvals=feval(fnf,z(1,:)',z(2,:)');

      % Compute all the integrals over T_i:

      I=trans.j*(V'*(qwts.*fvals));

      % Loop over all (global) indices related to this triangle.

      for j=1:id

         % Get the indices of the node

         if ll(j)>0 % (There's nothing to do if this node is not free.)

            % Add add the contribution to the right hand side

            F(ll(j))=F(ll(j))+I(j);

         end

      end

   end

   % Now handle the inhomogeneous Dirichlet data (if any),
   % provided there is a constrained node on this triangle:

   if any(ll<0) & ~isempty(g)

      % Compute quantities in common to all the integrals:

      if nkflag
         scale=fnk*trans.j;
         ghat=qwts;
      else
         scale=trans.j;
         ghat=feval(fnk,z(1,:)',z(2,:)').*qwts;
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

      % Transform the gradients to the reference triangle:

      Grads1=zeros(2,npts,id);
      for ii=1:id
         Grads1(:,:,ii)=trans.J'\[Vs(:,ii)';Vt(:,ii)'];
      end

      % Compute the gradients of the function G at the quadrature
      % nodes on T_R:

      Ggrads=zeros(2,npts);
      for ii=1:id
         Ggrads=Ggrads+w(ii)*Grads1(:,:,ii);
      end
      for r=1:id
         llr=ll(r);
         if llr>0

            I=scale*((Grads1(1,:,r).*Ggrads(1,:)+...
                      Grads1(2,:,r).*Ggrads(2,:))*ghat);
            F(llr)=F(llr)-I;

         end
      end

   end

   % Now handle the inhomogeneous Neumann data, if any

   if ~isempty(h)

      % Loop over the three edges and compute the contribution
      % of each:

      for j=1:3

         % There's nothing to do unless this edge is a free
         % boundary edge:

         eptr=-T.EdgeEls(abs(T.Elements(i,j)),2);
         if eptr>0

            % Interpolate the boundary function at the
            % quadrature nodes:

            hvals=V1*h(eptr,:)';

            ii=T.Edges(abs(T.Elements(i,j)),:);

            % Get the endpoints of the edge:

            epts=T.Nodes(ii([1,d+1]),:);

            % Compute the length of the edge:

            len=norm(epts(2,:)-epts(1,:));

            % Now apply the quadrature rule, computing all of the
            % integrals simultaneously

            I=(0.5*len)*(V1'*(qwts1.*hvals));

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
