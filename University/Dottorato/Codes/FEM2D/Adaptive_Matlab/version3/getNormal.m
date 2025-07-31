function n=getNormal(T,i,j)

% n=getNormal(T,i,j)
%
%   This function computes the outward-pointing unit
%   normals, at the d+1 edge nodes, to the jth edge
%   of triangle T_i (d is the degree of the mesh).
%   j is a local index (j=1,2,3).
%
%   The output is a 2 by (d+1) array; each column
%   contains one normal vector.  Notice that each
%   column is the same if the edge is straight.  If
%   the true edge is curved, an isoparametric element
%   is used, and the normal vectors are not all the
%   same.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

d=T.Degree;

e=T.Elements(i,j);
if ~T.EdgeCFlags(abs(e))

   % The edge is straight; all the normals are the same:

   c=T.Nodes(T.Edges(abs(e),[1,d+1]),:);
   if e>0
      n=[c(2,2)-c(1,2);c(1,1)-c(2,1)];
   else
      n=[c(1,2)-c(2,2);c(2,1)-c(1,1)];
   end
   n=n/norm(n);
   n=n*ones(1,d+1);

else

   % The edge is curved, so the normals are different:

   nodes=getNodes(T,i);
   TR=RefTri(d);
   inodes=getNodes(TR,1);
   s=linspace(0,1,d+1)';
   if e>0
      enodes=[1-s,s];
   else
      enodes=[s,1-s];
   end
   [Vs,Vt]=EvalNodalBasisGrads(inodes,enodes);

   n=[(Vt*nodes(:,2)-Vs*nodes(:,2))';
      (Vs*nodes(:,1)-Vt*nodes(:,1))'];
   for i=1:d+1
      n(:,i)=n(:,i)/norm(n(:,i));
   end

end
