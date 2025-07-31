%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solves the linear equation system A*x = b
%
%   function call
%      function phi = solveSys(Asys, b)
%
%   input variables
%      Asys     ...system matrix
%      b        ...right hand side of linear equation
%
%   output variables
%      phi      ...solution of the linear equation system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function phi = solveSys(Asys, b)

phi = Asys\b ;