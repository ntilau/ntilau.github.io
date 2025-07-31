function T=readMesh2(filename)

% T=readMesh2('filename')
%
%   This function reads the mesh T from the file named
%   'filename'.  The format of the file is as follows:
%
%         Degree
%         Nt
%         Elements (Nt by 3 array)
%         IntNodes (Nt by id-3d array)
%         Ne
%         Edges (Ne by 2 array)
%         EdgeEls (Ne by 2 array)
%         EdgeCFlags (Ne by 1 array)
%         Nv
%         Nodes (Nv by 2 array)
%         NodePtrs (Nv by 1 array)
%         Nf
%         FNodePtrs (Nf by 1 array)
%         Nc
%         CNodePtrs (Nc by 1 array)
%         Nb
%         FBndyEdges (Nb by 1 array)
%         Nr (number of refinements, plus 1)  (Degree==1 only)
%         LevelNodes (Nr by 1 array)  (Degree==1 only)
%         NodeParents (Nv by 2 array)  (Degree==1 only)
%         [Bases  (Nt by 1 array)]
%
%   The Bases array is optional.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

fid=fopen( filename,'r' );
if fid==-1
   error(['Cannot open file ',filename,' for reading'])
end

T.Degree=fscanf( fid,'%d\n',1 );
if T.Degree<1
   error(['File ',filename,' does not contain a mesh of degree d>=1'])
end
d=T.Degree;
id=(d+1)*(d+2)/2;
Nt=fscanf( fid,'%d\n',1 );
T.Elements=fscanf( fid,'%d %d %d\n',[3,Nt] )';
if T.Degree>2
   T.IntNodes=fscanf( fid,'%d',[id-3*d,Nt] )';
end
Ne=fscanf( fid,'%d\n',1 );
T.Edges=fscanf( fid,'%d %d\n',[d+1,Ne] )';
T.EdgeEls=fscanf( fid,'%d %d\n',[2,Ne] )';
T.EdgeCFlags=fscanf( fid,'%d\n',Ne );
Nv=fscanf( fid,'%d\n',1 );
T.Nodes=fscanf( fid,'%e %e\n',[2,Nv] )';
T.NodePtrs=fscanf( fid,'%d\n',Nv );
Nf=fscanf( fid,'%d\n',1 );
T.FNodePtrs=fscanf( fid,'%d\n',Nf );
Nc=fscanf( fid,'%d\n',1 );
T.CNodePtrs=fscanf( fid,'%d\n',Nc );
Nb=fscanf( fid,'%d\n',1 );
T.FBndyEdges=fscanf( fid,'%d\n',Nb );
if d==1
   Nr=fscanf( fid,'%d\n',1 );
   T.LevelNodes=fscanf( fid,'%d\n',Nr );
   T.NodeParents=fscanf( fid,'%d %d\n',[2,Nv] )';
end

[tmp,cnt]=fscanf( fid,'%d\n',Nt );
if cnt==Nt
   T.Bases=tmp;
end
[tmp,cnt]=fscanf( fid,'%s\n',1 );
if cnt==1
   T.BndyFcn=tmp;
end

fclose( fid );
