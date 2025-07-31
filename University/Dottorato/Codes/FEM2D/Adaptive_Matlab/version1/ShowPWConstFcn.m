function ShowPWConstFcn(T,U)

% ShowPWConstFcn(T,U)
%
%   This function draws a surface plot of a piecewise
%   constant function defined on a triangular mesh.
%   The inputs are T, the mesh and the vector U, giving
%   the values of the function on the triangles.
%
%   For a description of the data structure T, see
%   "help Mesh1".


%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

Nt=size(T.Elements,1);
if length(U)~=Nt
   error('Input vector has wrong length')
end

Z=zeros(3*Nt,1);
Z(1:3:3*Nt-2)=U;
Z(2:3:3*Nt-1)=U;
Z(3:3:3*Nt)=U;
tri=getTriNodeIndices1(T);
t=reshape(tri',3*Nt,1);
tri=reshape(1:3*Nt,3,Nt)';
X=T.Nodes(t,1);
Y=T.Nodes(t,2);

trisurf(tri,X,Y,Z,'LineWidth',2)
