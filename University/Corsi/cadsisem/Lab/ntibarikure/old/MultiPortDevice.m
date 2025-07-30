function [ Sf, Sinfo, Error ] = ...
    MultiPortDevice( TwoPrt, Nto1, OPrt, FS , Symmetry )

OPrt = 0;
% the port parameter are only needed if each 2-port segments is made of a
% multistep device.
% Nto1{1}.SideOne{1}.TwoPortDevicePort = 2;
% Nto1{1}.SideOne{2}.TwoPortDeviceIndex = 2;
% Nto1{1}.SideOne{2}.TwoPortDevicePort = 2;
% Nto1{1}.SideTwo.TwoPortDevicePort = 1;

% Assigning Segments location
for i=1:(length(TwoPrt)-1)
    WGS1{i}= TwoPrt{Nto1{1}.SideOne{i}.TwoPortDeviceIndex};
end
WGS2 = TwoPrt{Nto1{1}.SideTwo.TwoPortDeviceIndex};

% [WaveGuideStructure,Symmetry,Error] = StructureCheck(WGS1);
% if (DumpError(Error))
%     Sf = 0;
%     return;
% end
% 
% if (flag)
%     ShowGeo(WGS1,1);
% end
% 
[FS,Error] = FrequencyCheck(FS);
if (DumpError(Error))
    Sf = 0;
    return;
end 

% Calculate secondary parameters
for i=1:length(WGS1)
    [ WGS1{i}, Error ] = OrderModes( WGS1{i}, Symmetry );
    [ WGS1{i} ] = EigenModes( WGS1{i} );
    [ WGS1{i} ] = NormCoeff( WGS1{i} );
end
[ WGS2, Error ]    = OrderModes( WGS2, Symmetry );
[ WGS2 ] = EigenModes( WGS2 );
[ WGS2 ] = NormCoeff( WGS2 );

% Report modal parameters
for i=1:length(WGS1)
    Sinfo{i}.mh = WGS1{i}.mh;
    Sinfo{i}.nh = WGS1{i}.nh;

    Sinfo{i}.me = WGS1{i}.me;
    Sinfo{i}.ne = WGS1{i}.ne;
end
Sinfo{length(TwoPrt)}.mh = WGS2.mh;
Sinfo{length(TwoPrt)}.nh = WGS2.nh;

Sinfo{length(TwoPrt)}.me = WGS2.me;
Sinfo{length(TwoPrt)}.ne = WGS2.ne;

% Evaluate freq sweeped scattering matrices
f = FS.f;
c = 299792458;
    
for nf=1:length(f)
    lambda = c/f(nf);
    k0 = 2*pi/lambda;
           
    for i=1:length(WGS1)
        [ WGS1{i} ] = WaveNumbers( WGS1{i}, k0 );
        [ WGS1{i} ] = DelayMatrix( WGS1{i}, k0 );
    end
    [ WGS2 ] = WaveNumbers( WGS2, k0 );
    [ WGS2 ] = DelayMatrix( WGS2, k0 );
    
    % nbrPorts counts the number of ports our structure has
    nbrPorts = 0;
    
    S_InTwoPrt = [];
    % for each segment
    for i=1:length(WGS1)
        S_TwoPrt{i} = [ [zeros(size(WGS1{i}.D)) , WGS1{i}.D] ; ...
            [WGS1{i}.D, zeros(size(WGS1{i}.D))] ];        
        S_InTwoPrt = blkdiag(S_InTwoPrt,S_TwoPrt{i});
        nbrPorts = nbrPorts + 1 ;
    end
    S_TwoPrt{length(TwoPrt)} = [ [zeros(size(WGS2.D)) , WGS2.D] ; ...
            [WGS2.D, zeros(size(WGS2.D))] ];
    nbrPorts = nbrPorts + 1 ;
    
    % for the junction
    S_Nto1 = Nto1Step( WGS1, WGS2, k0);
    nbrPorts = nbrPorts * 3;

    % build the GSM
    GSM = blkdiag(S_InTwoPrt, [S_Nto1.S11 S_Nto1.S12 ; ...
        S_Nto1.S21 S_Nto1.S22], S_TwoPrt{length(TwoPrt)});
    

       
    % Condensation routine
    loop = 1;
    Order = 1:nbrPorts;
    Port_index = 2; % first of the ports to merge
    Junction_index = nbrPorts - 1 - length(TwoPrt); % first of the junction ports
    reducedGSM{loop} = GSM;
%     spy(reducedGSM{loop})
%     pause

    while(nbrPorts > length(TwoPrt))
%         Order(Port_index)
%         Order(Junction_index)
        reducedGSM{loop+1} = Condense( reducedGSM{loop}, size(WGS2.D), Order(Port_index),...
            Order(Junction_index), nbrPorts);
        Order(Port_index) = 0;
        Order(Junction_index) = 0;
        Port_index = Port_index + 1;
        Junction_index = Junction_index - 1;
        Order = find(Order); % eliminates zeros
        Order = find(Order); % reset indices for next condense
        nbrPorts = length(Order);
        loop = loop + 1;
%         spy(reducedGSM{loop})
%         pause
    end
    
    Sf{nf} = reducedGSM{loop};
    
end

