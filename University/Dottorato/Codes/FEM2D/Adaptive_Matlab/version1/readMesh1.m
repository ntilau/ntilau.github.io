function T=readMesh1(filename)

% T=readMesh1('filename')
%
%   This function reads the mesh T from the file named
%   'filename'.  The format of the file is as follows:
%
%         Nt
%         Elements (Nt by 3 array)
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
%         Nr (number of refinements, plus 1)
%         LevelNodes (Nr by 1 array)
%         NodeParents (Nv by 2 array)
%         [Bases  (Nt by 1 array)]
%
%   The Bases array need not be present.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

fid=fopen( filename,'r' );
if fid==-1
   error(['Cannot open file ',filename,' for reading'])
end

T.Degree=1;
d=fscanf( fid,'%d\n',1 );
if d~=1
   error(['File ',filename,' does not contain a mesh of degree 1'])
end
Nt=fscanf( fid,'%d\n',1 );
T.Elements=fscanf( fid,'%d %d %d\n',[3,Nt] )';
Ne=fscanf( fid,'%d\n',1 );
T.Edges=fscanf( fid,'%d %d\n',[2,Ne] )';
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
Nr=fscanf( fid,'%d\n',1 );
if Nr>1
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
