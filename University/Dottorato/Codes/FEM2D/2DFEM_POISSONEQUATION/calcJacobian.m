%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation of Jacobian
%
%   function call
%      function [a, b, c] = calcJacobian(project, element)
%
%   input variables
%      project  ...struct with information about the elements (nodes,
%                  edges, numbering)
%      element  ...number of current finite element
%
%   output variables
%      a, b, c  ...parameters for transformation local<->global
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [jacobi, detJ] = calcJacobian(project, element)

% global coordinates of finite element (ii)
x1 = project.netz.node(element.node(1)).x ; %1
x2 = project.netz.node(element.node(2)).x ; %2
x3 = project.netz.node(element.node(3)).x ; %3
y1 = project.netz.node(element.node(1)).y ; %1
y2 = project.netz.node(element.node(2)).y ; %2
y3 = project.netz.node(element.node(3)).y ; %3
 
jacobi = [x1-x3 x2-x3 ; y1-y3 y2-y3] ;
detJ = x1*y2 - x1*y3 -x3*y2 - x2*y1 + x2*y3 + x3*y1 ;