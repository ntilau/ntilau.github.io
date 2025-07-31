function z=EvalPWPolyFcn2(nodes,T,U,g)

% z=EvalPWPolyFcn2(nodes,T,U,g)
%
%   This function evaluates the piecewise polynomial
%   defined on the mesh T by the nodal values U (free nodes)
%   and g (constrained nodes) at the points given in the
%   input array nodes.  nodes is a k by 2 array, and the
%   output is the k by 1 array z.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

if nargin<4 | isempty(g)
   g=zeros(length(T.CNodePtrs),1);
end

% Combine the nodal values:

U1=zeros(length(T.NodePtrs),1);
U1(T.FNodePtrs)=U;
U1(T.CNodePtrs)=g;

% Allocate the output variable:

z=zeros(size(nodes,1),1);

% Get the node-triangle list:

tris=getTriNodeIndices(T);
d=T.Degree;
if d>1
   tris=tris(:,1:d:2*d+1);
end

% Find which triangles contain the points:

t=tsearch(T.Nodes(:,1),T.Nodes(:,2),tris,nodes(:,1),nodes(:,2));

% Sort the triangles and points:

[t,j]=sort(t);
nodes=nodes(j,:);

% Loop over the triangles and compute the values:

k=1;
N=length(t);
while k<=N

   % Get all the points in this triangle:

   i=find(t==t(k));

   % Extract the interpolation nodes on this triangle:

   [c,tt,ll]=getNodes(T,t(k));

   % Evaluate the nodal basis functions at the evaluation nodes:

   V=EvalNodalBasisFcns(c,nodes(i,:));

   % Compute the desired values:

   z(j(i))=V*U1(ll);

   % Skip past the processed points:

   k=k+length(i);

end
