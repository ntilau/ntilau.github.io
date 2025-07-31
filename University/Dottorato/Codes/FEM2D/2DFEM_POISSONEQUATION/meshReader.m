function netz = meshReader( dateiName, boundaryDim, materialDim ) 

% erzeugung der Dateinamen 
nodeName = strcat( dateiName, '.node' );
edgeName = strcat( dateiName, '.edge' ); 
elemName = strcat( dateiName, '.ele' ); 

% lesen der Knoten
fid = fopen( nodeName );
if fid == -1
    error( 'kann %s nicht ˆffnen', nodeName );
end
nodeCnt = fscanf( fid, '%i' , 1 );
nodeDim = fscanf( fid, '%i' , 1 );
attrib1 = fscanf( fid, '%i' , 1 );
attrib2 = fscanf( fid, '%i' , 1 );

if nodeDim ~= 2 | attrib1 ~= 0 | attrib2 ~=1
    error( 'falsches Knotenformat' );
end

for cnt = 1:nodeCnt
    nodeId = fscanf( fid, '%i' , 1 );
    if nodeId ~= cnt - 1
        error( 'falsches Knotenformat' );
    end
    posx = fscanf( fid, '%g' , 1 );
    posy = fscanf( fid, '%g' , 1 );
    boundNr = fscanf( fid, '%i', 1 );
    netz.node( nodeId + 1 ).x = posx;
    netz.node( nodeId + 1 ).y = posy;
    netz.node( nodeId + 1 ).boundNr = boundNr;
    if ( boundNr > boundaryDim )
        error( 'zu groﬂe Boundarynummer' );
    end
end
fclose( fid );

% lesen der Kanten
fid = fopen( edgeName );
if fid == -1
    error( 'kann %s nicht ˆffnen', edgeName );
end
edgeCnt = fscanf( fid, '%i' , 1 );
attrib = fscanf( fid, '%i' , 1 );
if attrib ~=1
    error( 'falsches Kantenformat' );
end

for cnt = 1:edgeCnt
    edgeId = fscanf( fid, '%i' , 1 );
    if edgeId ~= cnt - 1
        error( 'falsches Kantenformat' );
    end
    n0Id = fscanf( fid, '%i' , 1 );
    n1Id = fscanf( fid, '%i' , 1 );
    boundNr = fscanf( fid, '%i', 1 );    
    netz.edge( edgeId + 1).n0  = n0Id + 1;
    netz.edge( edgeId + 1).n1 = n1Id + 1;    
    netz.edge( edgeId + 1).boundNr = boundNr; 
    if boundNr > boundaryDim 
        error( 'zu groﬂe Boundarynummer' );
    end

end
fclose( fid );

% lesen der elemente 
fid = fopen( elemName, 'r' );
if fid == -1
    error( 'kann %s nicht ˆffnen', elemName );
end
elemCnt = fscanf( fid, '%i' , 1 );
nodeCnt = fscanf( fid, '%i' , 1 ); %muss = 3 sein
attrib = fscanf( fid, '%i' , 1 ); %muss = 1 sein

if attrib ~=1 | nodeCnt ~=3
    error( 'falsches Elementformat' );
end

for cnt = 1:elemCnt
    elemId = fscanf( fid, '%i' , 1 );
    if elemId ~= cnt - 1
        error( 'falsches Elementformat' );
    end
    n0Id = fscanf( fid, '%i' , 1 );
    n1Id = fscanf( fid, '%i' , 1 );
    n2Id = fscanf( fid, '%i' , 1 );
    matNr = fscanf( fid, '%i', 1 );    
    netz.elem( elemId + 1).node( 1 ) = n0Id + 1;
    netz.elem( elemId + 1).node( 2 ) = n1Id + 1;    
    netz.elem( elemId + 1).node( 3 ) = n2Id + 1;    
    netz.elem( elemId + 1).matNr = matNr;  
    if matNr > materialDim
        error( 'zu groﬂe Materialnummer' );
    end
end
fclose( fid );

% Nun weise den Elementen ihre Kanten zu

% erzeuge Nachbarschaftsmatrix
adjMat = sparse( nodeCnt, nodeCnt );
for cnt = 1:edgeCnt
    n0Id = netz.edge(cnt).n0;
    n1Id = netz.edge(cnt).n1;
    % der Einfachheithalber symmetrisch aufgebaut
    adjMat( n0Id, n1Id ) = cnt;
    adjMat( n1Id, n0Id ) = cnt;
end

% weise Elementen Kanten zu
for cnt = 1:elemCnt
    
    n0Id = netz.elem( cnt ).node( 1 );
    n1Id = netz.elem( cnt ).node( 2 );
    n2Id = netz.elem( cnt ).node( 3 );
    
%     edge0Id = adjMat( n1Id, n2Id ); % entgegengesetzt zu Knoten 0
%     edge1Id = adjMat( n0Id, n2Id );
%     edge2Id = adjMat( n0Id, n1Id );
    edge1Id = adjMat( n1Id, n2Id ); 
    edge2Id = adjMat( n0Id, n2Id );
    edge0Id = adjMat( n0Id, n1Id );
    
    netz.elem( cnt ).edge( 1 ) = edge0Id;
    netz.elem( cnt ).edge( 2 ) = edge1Id;
    netz.elem( cnt ).edge( 3 ) = edge2Id;
    if edge0Id == 0 | edge1Id == 0 | edge2Id == 0
        error( 'unbekannte Kante im elem-file' );
    end
   
end
