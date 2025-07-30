function [alpha]=linesearch(p,delta,Delta)

%
% Ricerca lineare partendo da d in direzione
% delta per i metodi deterministici
%
% (C) 2001 Stefano Selleri
%

N = length(p);
rho = 0.33;

alpha0=0.;
alpha1=0.00005;

cost0  = cost(p+alpha0*delta');
cost1  = cost(p+alpha1*delta');
dcost0 = gcost(p,Delta)*delta;

while(rho*dcost0*alpha1+cost0<cost1)
   
   alpha1=alpha1/2;
   cost1=cost(p+alpha1*delta');
   
end

alpha=alpha1;

   