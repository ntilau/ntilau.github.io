function [bc, info] = boundaryReader( bcName ) 

% erzeugung der Dateinamen 
bcName = strcat( bcName, '.bc' );

% öffene der Datei
fid = fopen( bcName );
if fid == -1
    error( 'kann %s nicht öffnen', bcName );
end
bcDim = fscanf( fid, '%i' , 1 );
ii = 1 ;
jj = 1 ;
info.bcDim = bcDim ;

% lesen der Randbedingungen
for cnt = 1:bcDim
    bcId = fscanf( fid, '%i' , 1 );
    if bcId ~= cnt
        error( 'falsches Randbedingungsformat' );
    end
    str = fscanf( fid, '%s' , 1 );
    if strcmp( str,'dirichlet' ) == true 
        bc( cnt ).bcType = 1;
        bc( cnt ).dirVal = fscanf( fid, '%f' , 1 );
        info.dirichlet(ii) = cnt ;
        ii = ii + 1 ;
    elseif strcmp( str, 'dirichletSinX' ) == true
        bc( cnt ).bcType = 2;
        bc( cnt ).x0 = fscanf( fid, '%f' , 1 );
        bc( cnt ).x1 = fscanf( fid, '%f' , 1 );
        bc( cnt ).periode = fscanf( fid, '%f' , 1 );
    elseif strcmp( str,'neumann' ) == true
        bc( cnt ).bcType = 0;
        bc( cnt ).dirVal = fscanf( fid, '%f', 1 ) ;
        info.neumann(jj) = cnt ;
        jj = jj + 1 ;
    else
        error( 'falsches Randbedingungsformat' );
    end
end
fclose( fid );

