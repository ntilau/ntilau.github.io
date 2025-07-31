clc; clear all;
N=20;
%generate grid in the ring
rho = 1;
[x,y]=meshgrid(linspace(-rho,rho,N));
M = floor(2.5*N);
theta = linspace(0,2*pi*(M-1)/M,M);
xc = rho*cos(theta);
yc = rho*sin(theta);
x=x(:); y=y(:);
idx = find(sqrt((x).^2+(y).^2) <= (rho*(N-1)/N));
x=x(idx)+rho/N*(1-rand(size(x(idx))));
y=y(idx)+rho/N*(1-rand(size(y(idx))));
x = [x;xc(:)];
y = [y;yc(:)];
nod2xy=[x(:) y(:)];
%generate triangulation/mesh
el2nod=delaunay(nod2xy(:,1),nod2xy(:,2));
figure; triplot(el2nod,nod2xy(:,1),nod2xy(:,2)); hold on; 
plot(rho*cos(linspace(0,2*pi,100)), rho*sin(linspace(0,2*pi,100)), '-r');
axis tight; axis equal;

%Dirichlet boundary conditions
ringIdx = (size(nod2xy,1)-M+1):size(nod2xy,1);
bd{1}=[ringIdx.', 0*ones(M,1)];

%set PDE parameter values
alpha=ones(size(nod2xy,1),1);
beta=zeros(size(nod2xy,1),1);
s=ones(size(nod2xy,1),1);

u=fem2(nod2xy,el2nod,alpha,beta,s,bd);
%plot solution as points
% figure
% plot3(nod2xy(:,1),nod2xy(:,2),u,'.')
% rotate3d
%plot solution as a surface
tic
[u x y c]=fem2(nod2xy,el2nod,alpha,beta,s,bd);
toc
figure
fill3(x,y,u,c)
shading flat
colormap jet
rotate3d