%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Master Matrices
%
%   function call
%      function [Asys, Sa, Sb, Sc] = getMasterMat(project, order)
%
%   input variables
%      project  ...struct with information about the elements (nodes,
%                  edges, numbering)
%      order    ...order of nodal basis function
%
%   output variables
%      Asys     ...initalized system matrix
%      Sa,Sb,Sc ...element matrices to build stiffness matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Asys, Sa, Sb, Sc] = getMasterMat(project, order)

% initialize element matrices Sa, Sb, Sc
if order == 1  
    
    % initialize system matrix (later initialize as sparse!!!!)
    Asys = sparse(project.nodeDim, project.nodeDim) ;
    
    % master stiffness matrix
    Sa = 0.5 * [ 1  0 -1 ; 0  0  0  ; -1  0  1];
    Sb = 0.5 * [ 0  1 -1 ; 1  0 -1  ; -1 -1  2];
    Sc = 0.5 * [ 0  0  0 ; 0  1 -1  ;  0 -1  1];

elseif order == 2
    
    % initialize system matrix
    Asys = sparse(project.nodeDim+project.edgeDim, project.nodeDim+project.edgeDim) ;
    
    % master stiffness matrices
    Sa = 1/6*[ 3  0  1  0  0 -4;...
               0  0  0  0  0  0;...
               1  0  3  0  0 -4;...
               0  0  0  8 -8  0;...
               0  0  0 -8  8  0;...
              -4  0 -4  0  0  8 ] ;
    Sb = 1/6*[ 0 -1  1  4  0 -4;...
              -1  0  1  4 -4  0;...
               1  1  6  0 -4 -4;...
               4  4  0  8 -8 -8;...
               0 -4 -4 -8  8  8;...
              -4  0 -4 -8  8  8 ] ;
    Sc = 1/6*[ 0  0  0  0  0  0;...
               0  3  1  0 -4  0;...
               0  1  3  0 -4  0;...
               0  0  0  8  0 -8;...
               0 -4 -4  0  8  0;...
               0  0  0 -8  0  8 ] ;
    
else
    printf('please choose order 1 or 2...\n') ;
    
end %endif