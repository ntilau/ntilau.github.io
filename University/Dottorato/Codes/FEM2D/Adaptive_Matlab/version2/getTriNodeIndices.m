function ElList=getTriNodeIndices(T)

% ElList=getTriNodeIndices1(T)
%
%   This function creates the Nt by id triangle-node
%   list.  Each row corresponds to one triangle in
%   the mesh T and contains the indices of the
%   id=(d+1)(d+2)/2 vertices in T.Nodes (d is the
%   degree of the triangles).
%
%   For a description of the mesh T, see "help Mesh2".

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

d=T.Degree;
id=(d+1)*(d+2)/2;

Nt=size(T.Elements,1);
ElList=zeros(Nt,id);

for k=1:Nt
   [t1,t2,indices]=getNodes(T,k);
   ElList(k,:)=indices';
end
