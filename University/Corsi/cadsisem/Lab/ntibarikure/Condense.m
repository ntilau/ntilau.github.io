function S_ok = Condense( S, nbrModes, indexm, indexn , nbrPorts)

% S: matrix to condense
% nbrModes: nbr of modes for each parameter
% indexX: indices of the positions to merge

% building CDEF
C = ExtractPortS(S, nbrModes, indexm, indexm);
D = ExtractPortS(S, nbrModes, indexm, indexn) - eye(nbrModes);
E = ExtractPortS(S, nbrModes, indexn, indexm) - eye(nbrModes);
F = ExtractPortS(S, nbrModes, indexn, indexn);

% blockwise inversion
if(det(C) ~= 0)
    Xi = E*inv(C);
    Phi.nm = inv(Xi*D-F)*Xi;
    Phi.nn = -inv(Xi*D-F);
    %disp('##### Using C #####');
elseif(det(E) ~= 0)
    Xi = C*inv(E);
    Phi.nm = inv(D-Xi*F);
    Phi.nn = -inv(D-Xi*F)*Xi;
    %disp('##### Using E #####');
else
    warning('##### There a little problem with the matrices C and E!!! #####');
    return;
end
if(det(F) ~= 0)
    Psi = D*inv(F);
    Phi.mm = -inv(Psi*E-C);
    Phi.mn = inv(Psi*E-C)*Psi;
    %disp('##### Using F #####');
elseif(det(D) ~= 0)
    Psi = F*inv(D);
    Phi.mm = -inv(E-Psi*C)*Psi;
    Phi.mn = inv(E-Psi*C);
    %disp('##### Using D #####');
else
    warning('##### There a little problem with the matrices F and D!!! #####');
    return;
end

% blockwise inversion. ref: http://en.wikipedia.org/wiki/Invertible_matrix
% This method is a little bit limited when the WGs have proportional
% wavenumbers
% if(det(C) ~= 0)
%     M = inv(F-E*inv(C)*D);
%     Phi.mm = inv(C) + inv(C)*D*M*E*inv(C);
%     Phi.mn = -inv(C)*D*M;
%     Phi.nm = -M*E*inv(C);
%     Phi.nn = M;
%     disp('##### Using C #####');
% elseif(det(F) ~= 0 && det(D) ~= 0)
%     M = inv(C-D*inv(F)*E)
%     Phi.mm = M
%     Phi.mn = -M*D*inv(F)
%     Phi.nm = -inv(F)*E*M
%     Phi.nn = inv(F) + inv(F)*E*M*D*inv(F)
%     disp('##### Using F #####');
% else
%     warning('##### There a little problem with the matrices!!! #####');
%     return;
% end

% rebuilding matrix
S_ok=[];
idx = 1; % indexes for new matrix indexing
for i=1:nbrPorts
    if((i ~= indexm) && (i ~= indexn))
        jdx = 1;
        for j=1:nbrPorts
            if( (j ~= indexm) && (j ~= indexn) )
                Stmp = ExtractPortS(S, nbrModes, i, j) - ...
                    (ExtractPortS(S, nbrModes, i, indexm) * ...
                    (Phi.mm*ExtractPortS(S, nbrModes, indexm, j) + ...
                    Phi.mn*ExtractPortS(S, nbrModes, indexn, j))) - ...
                    (ExtractPortS(S, nbrModes, i, indexn) * ...
                    (Phi.nm*ExtractPortS(S, nbrModes, indexm, j) + ...
                    Phi.nn*ExtractPortS(S, nbrModes, indexn, j)));
                S_ok = InsertPortS(S_ok, Stmp, nbrModes, idx, jdx);
                jdx = jdx + 1;
            end
        end
        idx = idx + 1;
    end
end