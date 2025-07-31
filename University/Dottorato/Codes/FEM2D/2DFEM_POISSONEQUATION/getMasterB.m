%
%
%

function [b, bN] = getMasterB(project, order)

if order == 1
    
    bN = zeros(project.nodeDim, 1) ;
    b  = [0.5 0 0.5]' ;
    
elseif order == 2
    
    bN = zeros(project.nodeDim+project.edgeDim, 1) ;
    b  = 1/6 * [1 0 1 0 0 4]' ;
    
else

    printf('please choose order 1 or 2...\n') ;

end