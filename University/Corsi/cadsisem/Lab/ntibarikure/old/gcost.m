function [g]=gcost(p,Delta)

%
% Gradiente della funzione di costo
% per un array ad alimentazione unforme e 
% spaziatura non uniforme
%
% (C) 2001 Stefano Selleri
%

N = length(p);

for i=1:N
   
   dd = Delta;
   
   dm = p;
   dm(i) = p(i) - dd;
   cm = cost(dm);
   
   dp = p;
   dp(i) = p(i) + dd;
   cp = cost(dp);
   
   g(i)=(cp-cm)/(2*dd);
   
end;
