function S = ExtractPortS( Stot, SeleDim, index_i ,index_j)

% extracts the port Scattering element (all modal values)

S = Stot( (1+(index_i-1)*SeleDim(1)) : (index_i*SeleDim(1)), ...
    (1+(index_j-1)*SeleDim(2)) : (index_j*SeleDim(2)) );