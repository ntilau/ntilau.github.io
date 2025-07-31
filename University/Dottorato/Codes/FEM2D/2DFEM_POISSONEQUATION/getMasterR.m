%
%
%

function [r, rel] = getMasterR(project, order)

if order == 1
    
    r = zeros(project.nodeDim, 1) ;
    rel  = 1/6 * [1 1 1]' ;
    
elseif order == 2
    
    r = zeros(project.nodeDim+project.edgeDim, 1) ;
    rel  = 1/6 * [0 0 0 1 1 1]' ;
    
else

    printf('please choose order 1 or 2...\n') ;

end