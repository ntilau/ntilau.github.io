function solutionWriter( solutionMatrix, project, fileName ) 

solutionName = strcat( fileName, '.sol' );
fid = fopen( solutionName, 'w' );
[tmp solCnt] = size( solutionMatrix );
varCnt = project.nodeDim;

% Header
fprintf( fid, '%i ', varCnt );
fprintf( fid, '%i \n', solCnt );

% Schreiben der Daten
for cnt = 1 : varCnt
    fprintf( fid, '%i ', cnt - 1 );
    fprintf( fid, '%16.16f ', solutionMatrix( cnt,: ) );
    fprintf( fid, '\n' );
end


fclose( fid );