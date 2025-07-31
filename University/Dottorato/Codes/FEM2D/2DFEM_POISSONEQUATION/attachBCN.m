%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Attach neumann boundary conditions
%
%   function call
%      function bN = attachBCN(project, order, neumann)
%
%   input variables
%      project   ...struct with information about the elements (nodes,
%                  edges, numbering)
%      order     ...order of nodal basis function
%      neumann   ...boundary conditions number for neumann bc's
%
%   output variables
%      bN       ...rhs for neumann boundary conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function bN = attachBCN(project, order, neumann)

dimNode = project.nodeDim ;
dimEdge = project.edgeDim ;
dimElem = project.elemDim ;

[b, bN] = getMasterB(project, order) ;

for ii = 1:dimEdge
    
    edge = project.netz.edge(ii) ;
    
    if (~isempty(find(edge.boundNr == neumann))) %if neumann
        
        x1 = project.netz.node(edge.n0).x ;
        x3 = project.netz.node(edge.n1).x ;
        y1 = project.netz.node(edge.n0).y ;
        y3 = project.netz.node(edge.n1).y ;
    
        edgeLength = sqrt((x1-x3)^2+(y1-y3)^2) ;
        
        sigma = project.boundary(edge.boundNr).dirVal ;
        
        bel = sigma*edgeLength*b ;
    
        entries = find(bel ~= 0) ;
    
        bN(edge.n0) = bN(edge.n0) + bel(1) ; % edge nodes
        bN(edge.n1) = bN(edge.n1) + bel(3) ;

        if(~isempty(entries))
           for jj = 2:order                    % interp nodes
              count = dimNode + (jj-2)*dimEdge + ii ;
              bN(count) = bN(count) + bel(entries(jj+1)) ;
           end
        end
    end
end