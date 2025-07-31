function Stot = InsertPortS( Stot, S, nbrModes, index_i ,index_j)

% extracts the port Scattering element (all modal values)

Stot( (1+(index_i-1)*nbrModes(1)) : (index_i*nbrModes(1)), ...
    (1+(index_j-1)*nbrModes(2)) : (index_j*nbrModes(2)) ) = S(:,:);