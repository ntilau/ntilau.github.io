%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation of the System Matrix
%
%   function call
%      function Asys = getSysMatrix(project, order)
%
%   input variables
%      project  ...struct with information about the elements (nodes,
%                  edges, numbering)
%      order    ...order of nodal basis funtion can be chosen to 1 or 2
%      eps      ...material parameter
%
%   output variables
%      Asys     ...returns the system matrix of the linear system A*x=b
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Asys = getSysMatrix(project, order, eps)

num = (order+1)*(order+2)/2 ;  % number of nodal basis functions
dimNode = project.nodeDim ;    % initialize variables
dimEdge = project.edgeDim ;
dimElem = project.elemDim ;

% initialize elementstruct
local = struct('nodes', zeros(1, 3),...
               'edge' , zeros(3, order-1),...
               'face' , zeros(max(0,num-3*(order-1)-3), 1)) ;
               
% get master matrix
[Asys, Sa, Sb, Sc] = getMasterMat(project, order) ;
    
for ii = 1:dimElem
    % set element
    element = project.netz.elem(ii) ;
    
    % get values of this element
    vals = buildValArray(element, order, local, num, dimNode, dimEdge, dimElem);
    
    % calculate jacobian and its determinant
    [jacobi, detJ] = calcJacobian(project, element) ;
    
    % calculate factors for Sel
    a = (jacobi(1,2)^2+jacobi(2,2)^2) / detJ ;
    b = (-jacobi(2,2)*jacobi(2,1) - jacobi(1,2)*jacobi(1,1)) / detJ ;
    c = (jacobi(1,1)^2 + jacobi(2,1)^2) / detJ ;
  
    % stiffness matrix calculated in local coordinates
    Sel = eps * (a*Sa + b*Sb + c*Sc) ;

    % write calculated values in system matrix
    for jj = 1:num
        for kk = 1:num
            temp = Asys(vals(jj), vals(kk)) ;
            Asys(vals(jj), vals(kk)) = temp + Sel(jj,kk) ;
        end
    end 
end %endfor elements 