function [ Sf, Sinfo, TwoPortDevices, Nto1Connections,...
    ConnectedPorts, FrequencySweep, Error ] = ...
    MultiPortDevice( TwoPortDevices, Nto1Connections,...
    OpenPorts, ConnectedPorts, FrequencySweep, flag, Options)
% MultiPortDevice Main Function
% V 1.0 - 20 Nov. 2008
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
%  Sf              = cell array of single frequency GSMs 
%  Sinfo           = usefull informations on the ports
%  Error           = guess...
%

%
% 1 - VALIDATE ALL
%
Sf    = {};
Sinfo = {};
[ TwoPortDevices, Nto1Connections, OpenPorts, ConnectedPorts, ...
    FrequencySweep, Symmetry, Topology, Error ] = ...
    MultiPortDeviceValidate( TwoPortDevices, Nto1Connections, OpenPorts,...
    ConnectedPorts, FrequencySweep, flag, Options);
if (DumpError('|  +--+>',Error))
    return;
end

%
% 2 - PERFORM COMPUTATIONS
%
[ Sf, Sinfo, Error, TwoPortDevices, Nto1Connections, ConnectedPorts] = ...
    MultiPortDeviceSolve( TwoPortDevices, Nto1Connections, OpenPorts,...
    ConnectedPorts, FrequencySweep, Symmetry, Topology, Options);
if (DumpError('|  +--+>',Error))
    return;
end
