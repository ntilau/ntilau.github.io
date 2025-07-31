%  The Fem package uses a structure to describe a triangular mesh.
%  This structure contains a number of arrays, as described below.
%  The following notation is used to describe the arrays:
%
%       Nt: the number of triangles
%       T_1,T_2,...,T_{Nt}: the triangles
%
%       Nv: the number of nodes
%       z_1,z_2,...,z_{Nv}: the nodes
%
%       Nf: the number of free nodes
%       Nc: the number of constrained nodes
%
%       Ne: the number of edges
%       e_1,e_2,...,e_{Ne}: the edges
%
%       Nb: the number of free boundary edges
%
%       d: the degree of the mesh (d=1,2,3,...)
%
%       id: the number of nodes per triangle (id=(d+1)(d+2)/2)
%
%  Here are the arrays describing the mesh:
%
%       Degree: Integer. The degree of the elements (1=linear,
%               2=quadratic, etc.)
%
%       Elements: Nt by 3 array.  The ith row contains pointers into
%                 Edges, identifying the three edges of T_i, in
%                 counterclockwise order, and their orientations.
%                 Specifically, suppose Elements(i,j)=k.
%                 If k>0, then the jth edge of T_i is e_k, traced from
%                 its first endpoint to its second.  If k<0, then the
%                 jth edge of T_i is e_{-k}, traced from its second
%                 endpoint to its first.
%
%       IntNodes: Nt by (id-3d) array.  The ith row contains pointers
%                 into Nodes, identifying the interior nodes of
%                 T_i (Note: If d is 1 or 2, there are no interior
%                 nodes).
%
%       Edges: Ne by d+1 array. The ith row contains pointers into Nodes,
%              identifying the d+1 nodes on e_i. (Note: The nodes
%              are given in order, beginning with one endpoint and
%              ending with the other.)
%
%       EdgeEls: Ne by 2 array. The ith row contains pointers into
%                Elements, identifying the triangles on either side
%                of e_i. (If e_i is a constrained boundary edge, the
%                second pointer is zero. If e_i is a free boundary edge,
%                the second pointer is the negative of its index in
%                FBndyEdges.)
%
%       EdgeCFlags: Ne by 1 array. The ith entry is 1 if e_i is
%                   curved, and zero otherwise.
%
%       Nodes: Nv by 2 array.  The ith row contains the (x,y) coordinates
%              of z_i.
%
%       NodePtrs: Nv by 1 array.  If z_i is free, then NodePtrs(i) is the
%                 index of the node in FNodePtrs.  If z_i is constrained,
%                 then NodePtrs(i) is the negative of the index of the
%                 node in CNodePtrs.
%
%       FNodePtrs: Nf by 1 array.  The ith entry is the index of the ith
%                  free node in Nodes.
%
%       CNodePtrs: Nc by 1 array.  The ith entry is the index of the ith
%                  constrained node in Nodes.
%
%       FBndyEdges: Nb by 1 array. The ith entry is the index of
%                   the ith free boundary edge in Edges.
%
%
%  Optional: (added automatically by Refine1 for for meshes of degree 1)
%
%       LevelNodes: k by 1 array, where Refine1 has been applied
%                   k-1 times.  The nodes added during the ith
%                   refinement are numbered
%                      LevelNodes(i)+1,...,LevelNodes(i+1).
%                   If LevelNodes does not exist, then k is taken
%                   to be 1 and LevelNodes(1) is taken to be Nv.
%
%       NodeParents: Nv by 2 array.  If node z_i was obtained by
%                    refinement as the midpoint of the edge with
%                    endpoints z_j and z_k, then
%                          NodeParents(i,:)=[j,k].
%                    Otherwise,
%                          NodeParents(i,:)=[i,0].


%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).
