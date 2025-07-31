%This is an electrostatic example. It is a resistive element
%with a potential at the bottom equal to V=0 and at the top
%the electric potential is V=10. There is no net electric field
%towards the other sides of the square plate.
clc; clear all;
N=30;
fact=2; % for random point collocation
%generate grid
xn=linspace(0,1,N);
[x,y]=meshgrid(xn);
M = floor(2.1*N);
theta = linspace(0,2*pi*(M-1)/M,M);
xc = .5+ .5*cos(theta);
yc = .5+ .5*sin(theta);
x=x(:);
y=y(:);
idx = find(sqrt((x-.5).^2+(y-.5).^2) <= (.5*(N-1)/N));
x=x(idx)+(.5-rand(size(x(idx))))./(fact*N);
y=y(idx)+(.5-rand(size(y(idx))))./(fact*N);
x = [x;xc(:)];
y = [y;yc(:)];
nod2xy=[x(:) y(:)];

% figure; plot(nod2xy(:,1),nod2xy(:,2),'*');
%generate triangulation/mesh
el2nod=delaunay(nod2xy(:,1),nod2xy(:,2));
figure; triplot(el2nod,nod2xy(:,1),nod2xy(:,2)); hold on; 
plot(.5+.5*cos(linspace(0,2*pi,100)), ...
  .5+.5*sin(linspace(0,2*pi,100)), '-r');
axis tight; axis equal;

% %find boundary nodes
% geom.a=find(nod2xy(:,2)==0);      %lower boundary
% geom.b=find(nod2xy(:,1)==1);      %right boundary
% geom.c=find(nod2xy(:,2)==1);      %upper boundary
% geom.d=find(nod2xy(:,1)==0);      %left boundary
% geom.b=setdiff(geom.b,[geom.a;geom.c]);
% geom.d=setdiff(geom.d,[geom.a;geom.c]);
% 
% %drawing mesh and gridpoints
% plotgrid2(nod2xy,el2nod)
% %plotting boundary nodes
% figure
% hold on
% plot(nod2xy(geom.a,1),nod2xy(geom.a,2),'.-b')
% plot(nod2xy(geom.b,1),nod2xy(geom.b,2),'.-r')
% plot(nod2xy(geom.c,1),nod2xy(geom.c,2),'.-b')
% plot(nod2xy(geom.d,1),nod2xy(geom.d,2),'.-r')
% legend('Dirichlet','Neumann',0)

%generate boundary conditions
% bd={};
% bd{1}=[geom.a zeros(N,1)];               %lower boundary (Dirichlet)
% bd{2}=[geom.b zeros(N-2,2)];             %right boundary (Neumann)
% bd{3}=[geom.c 10*ones(N,1)];             %upper boundary (Dirichlet)
% bd{4}=[geom.d zeros(N-2,2)];             %left boundary (Neumann)
ringIdx = (size(nod2xy,1)-M+1):size(nod2xy,1);
bd{1}=[ringIdx.', 0*ones(M,1)];


%set PDE parameter values
alpha=ones(size(nod2xy,1),1);
beta=zeros(size(nod2xy,1),1);
s=ones(size(nod2xy,1),1);

u=fem2(nod2xy,el2nod,alpha,beta,s,bd);
%plot solution as points
figure
plot3(nod2xy(:,1),nod2xy(:,2),u,'.')
rotate3d
%plot solution as a surface
[u x y c]=fem2(nod2xy,el2nod,alpha,beta,s,bd);
figure
fill3(x,y,u,c)
shading flat
colormap summer
rotate3d
% axis equal
