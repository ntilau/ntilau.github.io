function [f1, f2, f3, f4] = funzioni(x)

x = -pi:0.01:pi;
disp('f1 = 2sin(5x)^2');
f1 = 2*sin(5*x).^2
disp('f2 = cos(10x)^3');
f2 = cos(10*x).^3
disp('f3 = (sin(x))^2');
f3 = (sin(x)).^2
disp('f4 = 5cos(3.5x)^3');
f4 = 5*cos(3.5*x).^3

subplot(2,2,1),plot(x,f1,'k'),grid;Title('f1 = 2sin(5x)^2');
subplot(2,2,2),plot(x,f2,'b'),grid;Title('f2 = cos(10x)^3');
subplot(2,2,3),plot(x,f3,'g'),grid;Title('f3 = (sin(x))^2');
subplot(2,2,4),plot(x,f4,'r'),grid;Title('f4 = 5cos(3.5x)^3');

%OPZIONALE

%figure;
%plot(f1,f2,'k'),title('f2 in funzione di f1');
%hold on;
%plot(f1,f3,'g'),title('f3 in funzione di f1');
%plot(f1,f4,'r'),title('f4 in funzione di f1');
%hold off;