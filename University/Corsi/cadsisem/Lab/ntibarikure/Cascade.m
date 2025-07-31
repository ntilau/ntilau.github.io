function [ Stot ] = Cascade( WaveGuideStructure, S )
% Compute The complete cascade of the S and D matrices of the
% WaveGuideStructure
% V 1.0 - 26 Sept. 2007
% ------------------------------------------------------------------------
% [IN]
%    WaveGuideStructure - Waveguide structure, complete.
%    S - S matrices of the steps, complete
%
% [OUT]
%    Stot - S matrix of the whole device.
%

% There are indeed Np WaveGuideSegments, and Np-1 internal steps.
% To correctly take into account the length of the first and last 
% WaveGuideSegment we add a ficticious step number 0 and a ficticious
% step number 'Np' whose S matrices is that of a 0 length waveguide
% section.

% First ficticious step
S0.S11 = zeros(WaveGuideStructure{1}.Nh+WaveGuideStructure{1}.Ne);
S0.S12 = eye(WaveGuideStructure{1}.Nh+WaveGuideStructure{1}.Ne);
S0.S21 = eye(WaveGuideStructure{1}.Nh+WaveGuideStructure{1}.Ne);
S0.S22 = zeros(WaveGuideStructure{1}.Nh+WaveGuideStructure{1}.Ne);

% Taking this into account
Stot = SingleCascade(S0,WaveGuideStructure{1}.D,S{1});

% Taking all internal steps into account
Np = length(WaveGuideStructure);
if(Np>1)
    for p=2:(Np-1)
        Stot = SingleCascade(Stot,WaveGuideStructure{p}.D,S{p});
    end

    % Last ficticious step
    S0.S11 = zeros(WaveGuideStructure{Np}.Nh+WaveGuideStructure{Np}.Ne);
    S0.S12 = eye(WaveGuideStructure{Np}.Nh+WaveGuideStructure{Np}.Ne);
    S0.S21 = eye(WaveGuideStructure{Np}.Nh+WaveGuideStructure{Np}.Ne);
    S0.S22 = zeros(WaveGuideStructure{Np}.Nh+WaveGuideStructure{Np}.Ne);

    Stot = SingleCascade(Stot,WaveGuideStructure{Np}.D,S0);
    
end