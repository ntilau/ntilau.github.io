function asideTEcurrents(m,n,Nz,Ny)


for i=1:Nz
    z=(i-1)/(Nz-1);
    for j=1:Ny
        x=(j-1)/(Ny-1);
        
        Hx= sqrt(-1)*sin(m*pi*x)*exp(-sqrt(-1)*2*pi*z);
        Hy=0;
        Hz=cos(m*pi*x)*exp(-sqrt(-1)*2*pi*z);
        
        u(i,j)=2*pi*z;
        v(i,j)=x*2;
        
        Ju(i,j)= -Hx;
        Jv(i,j)= Hz;
    end
end

quiver(u,v,real(Ju),real(Jv),0.4);
axis([0 2*pi -1 2]);
axis 'equal';