function fd2d1(N,M)

d = 1/(N-1);

for i=1:N
	for j=1:N
		idx = (j-1)*N + i;
		A(idx,idx) = 1;
		if (i-1>0)
			A(idx,idx-1) = -1/4;
		end ;
		if(i<N)
			A(idx,idx+1) = -1/4;
		end;
		if (j-1>0)
		A(idx,idx-N) = -1/4;
		end;
		if (j<N)
			A(idx,idx+N) = -1/4;
		end;
	end;
end;

b = zeros(N*N,1);
for i=1:N
	idx = i;
	A(idx,:)=zeros(1,N*N) ;
	A(idx,idx)=1;
	idx = (N-1)*N+i;
	A(idx, :)=zeros(1,N*N) ;
	A(idx,idx)=1;
end;

for j=1:N
	idx = (j-1)*N+1;
	A(idx,:)=zeros(1,N*N) ;
	A(idx,idx)=1;
	idx = (j-1)*N+N; 
	A(idx,:)=zeros(1,N*N) ;
	A(idx,idx)=1;
end;

for i=(N-M)/2+1:(N+M)/2
	for j=(N-M)/2+1: (N+M)/2
		idx = (j-1)*N+i;
		A (idx,:)=zeros(1,N*N) ;
		A(idx,idx)=1 ;
		b(idx)=1;
	end;
end;
f = inv(A)*b;
for i=1:N
	for j=1:N
		idx = (j-1)*N + i;
		x(i,j) = (i-1)/(N-1) ;
		y(i,j) = (j-1)/(N-1) ;
		z(i,j) = f(idx) ;
	end;
end;

contour (x,y ,z) ;