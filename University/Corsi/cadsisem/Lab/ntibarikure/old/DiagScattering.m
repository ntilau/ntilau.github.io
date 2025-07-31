function [A] = DiagScattering(N)

A=[];


for i=1:N
    for j=1:N
        if(i+j == N+1 && i~=j)
            A(i,j)= 1;
        end
    end
end


if(mod(N,2) ~= 0)
    A((N+1)/2,(N+1)/2) = 1;
end