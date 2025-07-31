function ElList=getTriNodeIndices1(T)

% ElList=getTriNodeIndices1(T)
%
%   This function creates the Nt by 3
%   triangle-node list.  Each row corresponds
%   to one triangle in the mesh T and contains
%   the indices of the three vertices in T.Nodes.
%
%   See "help Mesh1" for a description of the mesh T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

Nt=size(T.Elements,1);
ElList=zeros(Nt,3);

for k=1:Nt
   [t1,t2,indices]=getNodes1(T,k);
   ElList(k,:)=indices';
end
