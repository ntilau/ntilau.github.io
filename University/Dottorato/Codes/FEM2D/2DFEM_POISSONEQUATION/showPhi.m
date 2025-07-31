%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show Solution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showPhi(phi, project, order)

[usedDim, tmp] = size(phi) ;
xcoord = zeros(usedDim, 1) ;
ycoord = zeros(usedDim, 1) ;
zcoord = zeros(usedDim, 1) ;

dimNode = project.nodeDim ;
dimEdge = project.edgeDim ;
dimElem = project.elemDim ;
    
for ii = 1 : dimNode
    xcoord(ii) = project.netz.node(ii).x ;
    ycoord(ii) = project.netz.node(ii).y ;
    zcoord(ii) = phi(ii) ;
end

if (order == 2)
    
for ii = 1 : dimEdge
    x1 = project.netz.node(project.netz.edge(ii).n0).x ;
    x2 = project.netz.node(project.netz.edge(ii).n1).x ;
    y1 = project.netz.node(project.netz.edge(ii).n0).y ;
    y2 = project.netz.node(project.netz.edge(ii).n1).y ;
    
    xcoord(dimNode + ii) = (x1 + x2) / 2 ;
    ycoord(dimNode + ii) = (y1 + y2) / 2 ;
    zcoord(dimNode + ii) = phi(dimNode+ii) ;
end

end

% 2D plot for potential
for ii = 1:dimElem
    TRI(ii, :) = project.netz.elem(ii).node ;
end

trisurf(TRI, xcoord, ycoord, zcoord, 'FaceColor', 'interp') ;
view([0 0 1]) ;
axis([min(xcoord) max(xcoord) min(ycoord) max(ycoord)]);

% 2D plot for e-field
gradX = zeros(dimNode, 1) ;
gradY = zeros(dimNode, 1) ;

for ii = 1:dimEdge
    edge = project.netz.edge(ii) ;
    x0 = project.netz.node(edge.n0).x ;
    x1 = project.netz.node(edge.n1).x ;
    y0 = project.netz.node(edge.n0).y ;
    y1 = project.netz.node(edge.n1).y ;
    gradX(edge.n0) = gradX(edge.n0) + (phi(edge.n0)-phi(edge.n1))*(x0-x1)/((x0-x1)^2+(y0-y1)^2) ;
    gradY(edge.n0) = gradY(edge.n0) + (phi(edge.n0)-phi(edge.n1))*(y0-y1)/((x0-x1)^2+(y0-y1)^2) ;
    gradX(edge.n1) = gradX(edge.n1) + (phi(edge.n1)-phi(edge.n0))*(x1-x0)/((x0-x1)^2+(y0-y1)^2) ;
    gradY(edge.n1) = gradY(edge.n1) + (phi(edge.n1)-phi(edge.n0))*(y1-y0)/((x0-x1)^2+(y0-y1)^2) ;
    
    temp(ii,1:2) = [project.netz.edge(ii).n0 project.netz.edge(ii).n1];
end

for ii = 1:dimNode
    [num, tmp] = size(find(temp == ii)) ;
    gradX(ii) = gradX(ii)/num ;
    gradY(ii) = gradY(ii)/num ;
    xcoord2(ii) = project.netz.node(ii).x ;
    ycoord2(ii) = project.netz.node(ii).y ;
end

figure;
quiver(xcoord2', ycoord2', gradX, gradY) ;
axis([min(xcoord2') max(xcoord2') min(ycoord2') max(ycoord2')]);            
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure;
% scatter3(xcoord, ycoord, zcoord, '.r');