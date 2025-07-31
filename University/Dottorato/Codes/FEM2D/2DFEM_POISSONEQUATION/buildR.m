%
%
%
function r = buildR(project, order, rho)

num = (order+1)*(order+2)/2 ;  % number of nodal basis functions

dimNode = project.nodeDim ;
dimEdge = project.edgeDim ;
dimElem = project.elemDim ;

% initialize elementstruct
local = struct('nodes', zeros(1, 3),...
               'edge' , zeros(3, order-1),...
               'face' , zeros(max(0,num-3*(order-1)-3), 1)) ;

[r, rel] = getMasterR(project, order) ;

for ii = 1:dimElem
    
    element = project.netz.elem(ii) ;
    
    [jacobi, detJ] = calcJacobian(project, element) ;
    
    tmp = rho*detJ*rel ;
    
    vals = buildValArray(element, order, local, num, dimNode, dimEdge, dimElem) ;
    
    for jj = 1:num
        r(vals(jj)) = r(vals(jj)) + tmp(jj) ;
    end
end