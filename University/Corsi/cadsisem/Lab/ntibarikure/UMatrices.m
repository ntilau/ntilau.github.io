function [U_h_1, U_h_2, U_e_1, U_e_2] = UMatrices(step);

U_h_1 = eye(step{1}.Nh);
U_h_2 = eye(step{2}.Nh); 
U_e_1 = eye(step{1}.Ne);
U_e_2 = eye(step{2}.Ne);