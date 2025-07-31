function project = projectReader( dateiName ) 

%material = materialReader( dateiName );
material(1).epsilonRelativ =2.1;
[boundary, bcInfo] = boundaryReader( dateiName );

[ tmp materialDim ] =  size( material );
[ tmp boundaryDim ] =  size( boundary );

netz = meshReader( dateiName, boundaryDim, materialDim );


project.netz = netz;
project.material = material;
project.boundary = boundary;
project.bcInfo = bcInfo ;

[ tmp nodeDim  ] = size( netz.node );
project.nodeDim = nodeDim;
[ tmp edgeDim  ] = size( netz.edge );
project.edgeDim = edgeDim;
[ tmp elemDim  ] = size( netz.elem );
project.elemDim = elemDim;

fprintf( '%i Elemente\n', elemDim );
fprintf( '%i Kanten\n', edgeDim );
fprintf( '%i Knoten\n', nodeDim );