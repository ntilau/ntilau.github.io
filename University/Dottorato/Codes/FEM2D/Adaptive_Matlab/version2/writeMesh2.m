function writeMesh2(filename,T)

% writeMesh2('filename',T)
%
%   This function writes the mesh T to the file named
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
%   The Bases array is only written if it is present as a field in
%   T.

%   This routine is part of the MATLAB Fem code that
%   accompanies "Understanding and Implementing the Finite
%   Element Method" by Mark S. Gockenbach (copyright SIAM 2006).

fid=fopen( filename,'w' );
if fid==-1
   error(['Cannot open file ',filename,' for writing'])
end

d=T.Degree;
id=(d+1)*(d+2)/2;
fprintf( fid,'%d\n',d );
fprintf( fid,'%d\n',size(T.Elements,1) );
fprintf( fid,'%d %d %d\n',T.Elements' );
if d>2
   fmt='';
   for j=1:id-3*d
      fmt=[fmt,'%d '];
   end
   fmt=[fmt,'\n'];
   fprintf( fid,fmt,T.IntNodes' );
end
fprintf( fid,'%d\n',size(T.Edges,1) );
fmt='';
for j=1:d+1
   fmt=[fmt,'%d '];
end
fmt=[fmt,'\n'];
fprintf( fid,fmt,T.Edges' );
fprintf( fid,'%d %d\n',T.EdgeEls' );
fprintf( fid,'%d\n',T.EdgeCFlags );
fprintf( fid,'%d\n',length(T.NodePtrs) );
fprintf( fid,'%.16e %.16e\n',T.Nodes' );
fprintf( fid,'%d\n',T.NodePtrs );
fprintf( fid,'%d\n',length(T.FNodePtrs) );
fprintf( fid,'%d\n',T.FNodePtrs );
fprintf( fid,'%d\n',length(T.CNodePtrs) );
fprintf( fid,'%d\n',T.CNodePtrs );
fprintf( fid,'%d\n',length(T.FBndyEdges) );
fprintf( fid,'%d\n',T.FBndyEdges );
if d==1 && ~isfield(T,'LevelNodes')
   Nv=length(T.NodePtrs);
   T.LevelNodes=Nv;
   T.NodeParents=[(1:Nv)',zeros(Nv,1)];
end
if d==1
   fprintf( fid,'%d\n',length(T.LevelNodes) );
   fprintf( fid,'%d\n',T.LevelNodes' );
   fprintf( fid,'%d %d\n',T.NodeParents' );
end
if isfield(T,'Bases')
   fprintf( fid,'%d\n',T.Bases );
end
if isfield(T,'BndyFcn') && ischar(T.BndyFcn)
   fprintf( fid,'%s\n',T.BndyFcn );
end

fclose( fid );
