%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Attach dirichlet boundary conditions
%
%   function call
%      function [Asys, bD, bN, r] = attachBCD(project, Asys, bN, r, order,
%                                   dirichlet)
%
%   input variables
%      project   ...struct with information about the elements (nodes,
%                  edges, numbering)
%      Asys      ...system matrix
%      bN        ...rhs for neumann boundary conditions
%      r         ...rhs for rho
%      order     ...order of nodal basis function
%      dirichlet ...boundary conditions number for dirichlet bc's
%
%   output variables
%      Asys     ...modified system matrix within dirichlet boundary
%                  conditions
%      bD       ...rhs for dirichlet boundary conditions
%      bN       ...rhs for neumann boundary conditions
%      r        ...rhs for rho
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Asys, bD, bN, r] = attachBCD(project, Asys, bN, r, order, dirichlet)

%initialize variables
[dimA, tmp] = size(Asys) ;
bD = zeros(dimA, 1) ;
mark = zeros(dimA, 1) ;
dimNode = project.nodeDim ;
dimEdge = project.edgeDim ;
dimElem = project.elemDim ;

% calculate b and adapt Asys with BC
for ii = 1:dimEdge
    % get boundary condition
    bcNr = project.netz.edge(ii).boundNr ;
    
    % get numbered position of nodes
    node1 = project.netz.edge(ii).n0 ;  % node1 of edge (ii)
    node2 = project.netz.edge(ii).n1 ;  % node2 of edge (ii)
    
    if (~isempty(find(bcNr==dirichlet)))    % if dirichlet    
        
        % insert value of dirichlet at this point
        bD(node1) = project.boundary(bcNr).dirVal ;
        bD(node2) = project.boundary(bcNr).dirVal ;
        
        % adapt system matrix
        Asys(node1, :) = 0 ;
        Asys(node1, node1) = 1 ;
        Asys(node2, :) = 0 ;
        Asys(node2, node2) = 1 ;
            
        % mark where an entry in b was made
        mark(node1) = 1 ;  
        mark(node2) = 1 ;
        
        for jj = 1:(order-1)
            count = dimNode + (jj-1)*dimEdge + ii ;
            bD(count) = project.boundary(bcNr).dirVal ;
            Asys(count, :) = 0 ;        % adapt
            Asys(count, count) = 1 ;    % adapt
            mark(count) = 1 ;           % mark
        end
    end %endif
end %endfor

% write all known to the rhs and kill the corresponding entries in Asys
mark0 = find(mark == 0) ; [term0, tmp] = size(mark0) ;
mark1 = find(mark == 1) ; [term1, tmp] = size(mark1) ;

temp = 0 ;  % reset value

for ii = 1:term0
    for jj = 1:term1
        temp = temp - Asys(mark0(ii), mark1(jj))*bD(mark1(jj)) ;
        bD(mark0(ii)) = temp ;
        Asys(mark0(ii), mark1(jj)) = 0 ;
    end
    temp = 0 ;
end

% kill corresponding entries in bN and r
for ii = 1:term1
    bN(mark1(ii)) = 0 ;
    r(mark1(ii)) = 0 ;
end