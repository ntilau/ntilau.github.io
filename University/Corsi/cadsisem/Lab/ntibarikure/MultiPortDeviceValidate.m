function [ TwoPortDevices, Nto1Connections, ...
    OpenPorts, ConnectedPorts, FrequencySweep, Symmetry, Topology, Error ] = ...
    MultiPortDeviceValidate( TwoPortDevices, Nto1Connections,...
    OpenPorts, ConnectedPorts, FrequencySweep, flag, Options)
% Validates all the objects defining a MultiPortDevice
% V 1.0 - 07 Nov. 2008
% ------------------------------------------------------------------------
% [IN]
%  TwoPortDevices = cell array of geometrical definition of
%                   TwoPortDevice structures, containing only Geometrical
%                   data at the moment
%  Nto1Connections = cell array of Nto1Device structures
%  OpenPorts       = cell array of PortPointer structures
%  FrequencySweep  = Frequency Sweep Structure
%  flag            = 0 nothing is drawn, 1 compact draw, 2 exploded draw
%
% [OUT]
%  All of the above, changed as necessary plus
%  Symmetry        = structure defining overall symmetry
%  Topology        = info on connected ports
%  Error           = guess...

disp (['+--+> BEGINNING of checks']);
Symmetry = struct();
Topology = struct();
%
% FIRST validate frequency sweep
%
disp (['|  +--+> Verifying Frequency Sweep']);
[FrequencySweep,Error] = FrequencySweepValidate(FrequencySweep);
if (DumpError('|  |  +--+>',Error))
    Error.AlreadyDumped=1;
    return;
end
%
% SECOND validates all TwoPortDevices
%
for i=1:length(TwoPortDevices)
    disp (['|  +--+> Verifying TwoPortDevices{',num2str(i),'}']);
    [TwoPortDevices{i}.D,Symmetry2P{i},Error] = ...
        TwoPortDeviceValidate(TwoPortDevices{i}.D);
    if (DumpError('|  |  +--+>',Error))
        Error.AlreadyDumped=1;
        return;
    end
end
% 
% THIRD validates all Nto1 junctions
%
% Bewate!!! Two Port devices too may be modified if necessity
% arises to match geometries.
for i=1:length(Nto1Connections)
    disp (['|  +--+> Verifying Nto1Connections{',num2str(i),'}']);
    [TwoPortDevices, Nto1Connections{i}, SymmetryNJ{i}, Error] = ...
        Nto1DeviceValidate(TwoPortDevices, Nto1Connections{i});
    if (DumpError('|  |  +--+>',Error))
        Error.AlreadyDumped=1;
        return;
    end
end
%
% FOURTH Evaluates global SYMMETRY
%
disp (['|  +--+> Checking global Symmetry']);
Symmetry.x = 1;
Symmetry.y = 1;
Symmetry.H = 1;
Symmetry.E = 1;
for i=1:length(TwoPortDevices)
    Symmetry.x = Symmetry.x * Symmetry2P{i}.x;
    Symmetry.y = Symmetry.y * Symmetry2P{i}.y;
    Symmetry.H = Symmetry.H * Symmetry2P{i}.H;
    Symmetry.E = Symmetry.E * Symmetry2P{i}.E;
end
for i=1:length(Nto1Connections)
    Symmetry.x = Symmetry.x * SymmetryNJ{i}.x;
    Symmetry.y = Symmetry.y * SymmetryNJ{i}.y;
    Symmetry.H = Symmetry.H * SymmetryNJ{i}.H;
    Symmetry.E = Symmetry.E * SymmetryNJ{i}.E;
end 
disp (['|  |  +--+> Global Symmetry is:']);
if (Symmetry.x) Xs='YES'; else Xs='No'; end
if (Symmetry.y) Ys='YES'; else Ys='No'; end
if (Symmetry.H) Hs='YES'; else Hs='No'; end
if (Symmetry.E) Es='YES'; else Es='No'; end
disp (['|  |  |  +--+> Symmetry along x      : ',Xs]);
disp (['|  |  |  +--+> Symmetry along y      : ',Ys]);
disp (['|  |  |  +--+> Uniformity on H-plane : ',Hs]);
disp (['|  |  |  +--+> Uniformity on E-plane : ',Es]);
    
%
% FIFTH Verifies topology
%
disp (['|  +--+> Verifying Topology']);
[ Topology, Error ] = ...
    MultiPortDeviceTopology( TwoPortDevices, Nto1Connections, OpenPorts);
if (DumpError('|  |  +--+>',Error))
    Error.AlreadyDumped=1;
    return;
end

%
% SIXTH Displays Device
%
disp (['|  +--+> Displaying device']);
if flag
    MultiPortDeviceDraw(TwoPortDevices, Nto1Connections, flag-1, Options);
end
if (DumpError('|  |  +--+>',Error))
    Error.AlreadyDumped=1;
    return;
end


