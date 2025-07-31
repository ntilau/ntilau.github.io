function [Dgamma_h_1, Dgamma_h_2, Dgamma_e_1, Dgamma_e_2] = DgammaMatrices(step)

Dgamma_h_1 = sqrt(-1)*diag(step{1}.kh.mn);
Dgamma_h_2 = sqrt(-1)*diag(step{2}.kh.mn);
Dgamma_e_1 = sqrt(-1)*diag(step{1}.ke.mn);
Dgamma_e_2 = sqrt(-1)*diag(step{2}.ke.mn);