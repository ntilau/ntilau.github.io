function S_ok = Condense( S, nbrModes, indexm, indexn , nbrPorts)

% S: matrix to condense
% nbrModes: nbr of modes for each parameter
% indexX: indices of the positions to merge

% build CDEF
C = ExtractPortS( S, nbrModes, indexm, indexm);

D = ExtractPortS( S, nbrModes, indexm, indexn) - ...
    eye(nbrModes);

E = ExtractPortS( S, nbrModes, indexn, indexm) - ...
    eye(nbrModes);

F = ExtractPortS( S, nbrModes, indexn, indexn);

% detC = det(C)
% detF = det(F)
% pause;

% blockwise inversion. ref: http://en.wikipedia.org/wiki/Invertible_matrix
if(det(C) ~= 0)
    M = inv(F-E*inv(C)*D);
    Phi.mm = inv(C) + inv(C)*D*M*E*inv(C);
    Phi.mn = -inv(C)*D*M;
    Phi.nm = -M*E*inv(C);
    Phi.nn = M;
%     'Using C'
elseif(det(F) ~= 0)
    M = inv(C-D*inv(F)*E);
    Phi.mm = M;
    Phi.mn = -M*D*inv(F);
    Phi.nm = -inv(F)*E*M;
    Phi.nn = inv(F) + inv(F)*E*M*D*inv(F);
%     'Using F'
else
    DumpError('There a little problem with the matrices!!!');
    return;
end



% rebuilding matrix
S_ok=[];
idx = 1; % indexes for new matrix indexing
for i=1:nbrPorts
    if( (i ~= indexm) && (i ~= indexn) )
        jdx = 1;
        for j=1:nbrPorts
            if( (j ~= indexm) && (j ~= indexn) )
                S_ok( (1+(idx-1)*nbrModes) : (idx*nbrModes), ...
                    (1+(jdx-1)*nbrModes) : (jdx*nbrModes) ) = ...
                    ExtractPortS( S, nbrModes, i, j) - ...
                    (ExtractPortS( S, nbrModes, i, indexm) * ...
                    ( Phi.mm*ExtractPortS( S, nbrModes, indexm, j) + ...
                    Phi.mn*ExtractPortS( S, nbrModes, indexn, j) )) - ...
                    (ExtractPortS( S, nbrModes, i, indexn) * ...
                    ( Phi.nm*ExtractPortS( S, nbrModes, indexm, j) + ...
                    Phi.nn*ExtractPortS( S, nbrModes, indexn, j)));
                jdx = jdx + 1;
            end
        end
        idx = idx + 1;
    end
end
% idx-1
% jdx-1
% spy(S_ok)
% pause