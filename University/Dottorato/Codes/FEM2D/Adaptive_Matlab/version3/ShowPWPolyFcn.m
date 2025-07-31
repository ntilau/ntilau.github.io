function ShowPWPolyFcn(T,U,g,lw)

% ShowPWPolyFcn(T,U,g,lw)
%
%   This function draws a surface plot of a piecewise
%   polynomial function defined on a triangular mesh.
%   The inputs are T, the mesh (see "help Mesh" for
%   details about this data structure) and the vector U,
%   giving the nodal values (at the free nodes) of the
%   function.
%
%   The optional argument g gives the nodal values at
%   the constrained nodes; if g is omitted, it is taken
%   to be the zero vector.
%
%   The optional input lw is the line width for the plot; the
%   default is lw=1.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4
   lw=1;
end

if nargin<3 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
end

% Handle the case of a piecewise linear function separately (since
% it can be graphed exactly):

if T.Degree==1

   ShowPWLinFcn1(T,U,g,lw);

% Handle the case in which the degree is greater than 1:

else

   % Get the number of triangles:

   Nt=size(T.Elements,1);

   % Decide how many evaluation nodes to add to each triangle to
   % get a smooth graph:

   kk=max([0,ceil(0.5*log2(1000/Nt)-0.25)]);

   % d is the degree of the elements (1=linear, 2=quadratic,etc.).

   d=T.Degree;

   % id is the number of interpolation nodes per triangle.

   id=round((d+2)*(d+1)/2);

   % Create the reference triangle and the evaluation nodes on it:

   TR=RefTri(d);
   TRD=RefTri(1);
   for i=1:kk
      TRD=Refine1(TRD);
   end
   enodes=TRD.Nodes;
   npts=size(enodes,1);

   % Evaluate the standard basis functions at the evaluation
   % nodes on TR:

   inodes=getNodes(TR,1);
   Vals=EvalNodalBasisFcns(inodes,enodes);

   % Loop over the triangles in the mesh and assemble all the
   % triangular patches separately:

   gnodes=zeros(Nt*npts,2);
   Z=zeros(Nt*npts,1);
   fac=4^kk;
   tris=zeros(Nt*fac,3);

   for k=1:Nt

      % Determine whether this triangle has a curved edge
      % (note that by convention, if there is a curved edge, it
      % must be the second edge):

      CurvedEdge=T.EdgeCFlags(abs(T.Elements(k,2))) & d>1;

      % Extract the nodes and nodal values on this triangle T:

      [coords,ll]=getNodes(T,k);
      i1=find(ll>0);
      i2=find(ll<0);
      v=zeros(id,1);
      v(i1)=U(ll(i1));
      v(i2)=g(-ll(i2));

      % Extract the coordinates of the vertices of the triangle:

      c=coords(1:d:2*d+1,:);

      % Transform the reference triangle to T.  How this is
      % done depends on whether the triangle has a curved
      % edge.

      if CurvedEdge

         % Get the evaluation nodes on T:

         ii=(k-1)*npts+1:k*npts;
         gnodes(ii,:)=Vals*coords;

      else

         trans=TransToRefTri(c);
         ii=(k-1)*npts+1:k*npts;
         gnodes(ii,:)=(trans.z1*ones(1,npts)+trans.J*enodes')';

      end

      % Get the values at the evaluation nodes on T:

      Z(ii)=Vals*v;

      % Define the subtriangles on T:

      tris1=getTriNodeIndices(TRD);
      tris((k-1)*fac+1:k*fac,:)=tris1+(k-1)*npts;

   end

   % Now call trimesh to plot all of the triangular patches:

   trimesh(tris,gnodes(:,1),gnodes(:,2),Z,'LineWidth',lw);

end
