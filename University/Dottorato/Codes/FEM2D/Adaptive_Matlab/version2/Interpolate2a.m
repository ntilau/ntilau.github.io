function [U1,g1]=Interpolate2a(T,T1,U,g)

% [U1,g1]=Interpolate2a(T,T1,U,g)
%
%   This function interpolates the piecewise
%   polynomial function U, defined on mesh T,
%   on the finer mesh T1.  T1 must be obtained
%   from T by exactly one application of Refine1.
%   (Note: This last assumption allows Interpolate2a
%   to work much faster than EvalPWPolyFcn2.)

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

% Handle the optional input g:

Nf=length(T.FNodePtrs);
Nc=length(T.CNodePtrs);
if nargin<4 | isempty(g)
   g=zeros(Nc,1);
end

% Allocate the output vectors:

Nf1=length(T1.FNodePtrs);
Nc1=length(T1.CNodePtrs);

U1=zeros(Nf1,1);
g1=zeros(Nc1,1);

% Get the interpolation nodes of the local basis functions
% (for mesh T) on the reference triangle.  The evaluation
% nodes will be the interpolation nodes for the finer mesh
% (determined in the main loop).

d=T.Degree;
id=(d+1)*(d+2)/2;
TR=RefTri(d);
d1=T1.Degree;
id1=(d1+1)*(d1+2)/2;
TR1=RefTri(d1);
inodes=getNodes(TR,1);

% Loop over the triangles of T1 and get the nodal values of U.
% (By this algorithm, most values in U1 are computed several
% times.)

Nt1=size(T1.Elements,1);
for i=1:Nt1

   % Get the index of the parent triangle in T:

   i1=floor((i-1)/4)+1;

   % Get the pointers to the nodes on the finer mesh:

   [coords1,ll1]=getNodes(T1,i);

   % Get the pointers to the nodes on the coarse mesh:

   [coords,ll,mm]=getNodes(T,i1);

   % Get the nodal values of the input function.

   w=zeros(id,1);
   j1=find(ll>0);
   j2=find(ll<0);
   w(j1)=U(ll(j1));
   w(j2)=g(-ll(j2));

   % Transform the large triangle to the reference
   % triangle:

   trans=TransToRefTri(coords(1:d:2*d+1,:));

   % Transform the interpolation nodes of the small
   % triangle to the reference triangle:

   enodes=(trans.J\(coords1'-trans.z1*ones(1,id1)))';

   % Evaluate the nodal basis functions at the evaluation
   % nodes:

   V=EvalNodalBasisFcns(inodes,enodes);

   % Evaluate the input function at the nodes on the
   % small triangle:

   w1=V*w;

   % Insert the values into U1 and g1:

   j1=find(ll1>0);
   j2=find(ll1<0);
   U1(ll1(j1))=w1(j1);
   g1(-ll1(j2))=w1(j2);

end
