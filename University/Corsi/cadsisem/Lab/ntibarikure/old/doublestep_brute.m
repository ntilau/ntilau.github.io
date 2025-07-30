clear
% Geometria
WGS{1}.a=0.01905;
WGS{1}.b=0.009525;
WGS{1}.Nmodes = 12;
WGS{1}.l = 0.01;
WGS{1}.xo=0;
WGS{1}.yo=0;

WGS{2}.a=0.01905;
WGS{2}.b=0.009525;
WGS{2}.Nmodes = 12;
WGS{2}.xo=0.000;
WGS{2}.yo=0.000;
WGS{2}.l = 0.01;

WGS{3}.a=0.01905;
WGS{3}.b=0.009525/2;
WGS{3}.Nmodes = 12;
WGS{3}.xo=0.000;
WGS{3}.yo=-0.009525/4;
WGS{3}.l = 0.01;

FS.start = 12.5*10^9;
FS.end   = 12.5*10^9;
FS.N     = 1;

N  = 21;
br = 2;
lr = 2;

bm = (WGS{1}.b + WGS{3}.b)/2;
lm = 0.007;

for i=1:N
    for j=1:N
         
        b = bm + (br*(i-1)/(N-1)-br/2)/1000;
        l = lm + (lr*(j-1)/(N-1)-lr/2)/1000;
        
        WGS{2}.b  = b;
        WGS{2}.l  = l;
        WGS{2}.yo = - (WGS{1}.b-WGS{2}.b)/2;
    
        [S,WGSx,FS] = MultiStepDevice(WGS,FS,0);

        bb(i,j) = b;
        ll(i,j) = l;
        
        S11(i,j) = S{1}.S11(1,1);
    end
end

surf(bb,ll,20*log10(abs(S11)));
