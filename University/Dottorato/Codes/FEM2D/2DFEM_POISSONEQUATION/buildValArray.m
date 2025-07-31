%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create global unique global numbering
%
%   function call
%      function vals = buildValArray(element, order, local, num, dimNode,
%      dimEdge, dimElem)
%
%   input variables
%      element  ...current element
%      order    ...order of nodal basis funtion can be chosen to 1 or 2
%      local    ...struct with global numbering
%      num      ...number of nodal basis functions
%      dimNode  ...number of nodes
%      dimEdge  ...number of edges
%      dimElem  ...number of elements
%
%   output variables
%      vals     ...array with global numbering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vals = buildValArray(element, order, local, num, dimNode, dimEdge, dimElem)

% store NODE
local.nodes = element.node ; % store node-numbers
vals = local.nodes ;         % write node coordinates in coords
    
% for each element it exists (order-1) interp. nodes per EDGE
for jj = 2:order
    local.edge(:, jj-1) = dimNode + (jj-2)*dimEdge + element.edge' ;
end
    
% write data in coords array
for jj = 1:3
    vals(4+(jj-1)*(order-1):3+jj*(order-1)) = local.edge(jj,:) ;
end
    
% interp. nodes per FACE
for jj = 1:max(0,num-3*(order-1)-3) 
    local.face(jj) = dimNode + (order-1)*dimEdge + (jj-1)*dimElem + ii;
    vals(3*order+jj) = local.face(jj) ;
end