function [ Sf, WaveGuideStructure, FrequencySweep, Error ] = ...
    MultistepDevice( WaveGuideStructure, FrequencySweep, flag )
% Computes Modes and Scattering matrix for a WaveGuideStructure
% composed by a series of WaveGuideSections over a Frequency Sweep
% V 1.0 - 26 Sept. 2007
% ------------------------------------------------------------------------
% [IN]
%   WaveGuideStructure = Waveguide Structure, containing only Geometrical
%                        data
%   FrequencySweep     = Frequency Sweep Structure
%   
% [OUT]
%   S - S Matrix of the device
%   WaveGuideStructure = Waveguide Structure, containing all 
%                        electromagnetic data
%   FrequencySweep     = Frequency Sweep Structure, augmented if needed
%

% Checking
[WaveGuideStructure,Symmetry,Error] = StructureCheck(WaveGuideStructure);
if (DumpError(Error))
    Sf = 0;
    return;
end

if (flag)
    ShowGeo(WaveGuideStructure,1);
end

[FrequencySweep,Error] = FrequencyCheck(FrequencySweep);
if (DumpError(Error))
    Sf = 0;
    return;
end    
    
% Frequency independent pre-processing
for p=1:length(WaveGuideStructure)
    % Prepares the required mode indices
    [WaveGuideStructure{p},Error] = OrderModes(WaveGuideStructure{p},Symmetry);
    if (DumpError(Error))
        Sf = 0;
        return;
    end    
  
    % Computes relative eigenvalues
    WaveGuideStructure{p} = EigenModes(WaveGuideStructure{p});
      
    % And normalization coefficients
    WaveGuideStructure{p} = NormCoeff(WaveGuideStructure{p});
end

% Frequency Loop
c = 299792458;
for nf=1:FrequencySweep.N
      
    lambda = c/FrequencySweep.f(nf);
    k0 = 2*pi/lambda;

    for p=1:length(WaveGuideStructure)
        % Compute modes wavenumbers at this frequency
        WaveGuideStructure{p} = WaveNumbers(WaveGuideStructure{p},k0);
    
        % Compute the delay matrix of the segment
        WaveGuideStructure{p} = DelayMatrix(WaveGuideStructure{p},k0);    
    end

    for p=1:length(WaveGuideStructure)-1;
        % For each pair of segments computes the S matrix of the
        % step in between
        SStep{p} = SingleStep (WaveGuideStructure, p, k0);
    end

    % Makes a cascade
    Stot = Cascade (WaveGuideStructure,SStep);

    % Rinormalizziamo
    Stot = Renormalize(WaveGuideStructure,Stot);
    
    Sf{nf}.S11 = Stot.S11;
    Sf{nf}.S12 = Stot.S12;
    Sf{nf}.S21 = Stot.S21;
    Sf{nf}.S22 = Stot.S22;
    
end
