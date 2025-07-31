function [ S ] = SingleCascade( SA, D, SB )
% Compute The cascade of two steps with an interposed waveguide section
% delaying by D
% V 1.0 - 26 Sept. 2007
% ------------------------------------------------------------------------
% [IN]
%    SA - S matrix of first step.
%    SB - S matrix of second step
%    D  - Delay matrix in between
%
% [OUT]
%    S - S matrix of the cascade.
%


P = inv(eye(size(D)) - D*SB.S11*D*SA.S22);
Q = inv(eye(size(D)) - D*SA.S22*D*SB.S11);

Sg = [[SA.S12,zeros(size(SA.S12,1),size(SB.S21,2))];...
      [zeros(size(SB.S21,1),size(SA.S12,2)),SB.S21]] * ...
    [[P*D*SB.S11,P];[Q,Q*D*SA.S22]] * ...
    [[D*SA.S21,zeros(size(SA.S21,1),size(SB.S12,2))];...
      [zeros(size(SB.S12,1),size(SA.S21,2)),D*SB.S12]] + ...
    [[SA.S11,zeros(size(SA.S11,1),size(SB.S22,2))];
      [zeros(size(SB.S22,1),size(SA.S11,2)),SB.S22]];
  
[NA,MA] = size (SA.S11);
[NB,MB] = size (SB.S22);

S.S11 =Sg(1:NA,1:MA);
S.S12 =Sg(1:NA,(MA+1):(MA+MB));
S.S21 =Sg((NA+1):(NA+NB),1:MA);
S.S22 =Sg((NA+1):(NA+NB),(MA+1):(MA+MB));

