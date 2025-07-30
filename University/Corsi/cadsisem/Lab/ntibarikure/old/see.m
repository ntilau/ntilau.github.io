load 'pathtooptimum.mat';
load 'sfieldmap.mat';

contour(bb,ll,20*log10(abs(S11)),[-10,-20,-30,-40,-60,-60,-70,-80,-90,-100]);

line(b,l);
axis([min(min(bb)) max(max(bb)) min(min(ll)) max(max(ll))]);