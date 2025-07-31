function [ Sf, WaveGuideStructure ] = MultiStep( WaveGuideStructure, k0, Symmetry)


nbrSegments = length(WaveGuideStructure);

for p=1:nbrSegments
%     [WaveGuideStructure{p},Error] = OrderModes(WaveGuideStructure{p},Symmetry);
%     WaveGuideStructure{p} = EigenModes(WaveGuideStructure{p});
%     WaveGuideStructure{p} = NormCoeff(WaveGuideStructure{p});
    WaveGuideStructure{p} = WaveNumbers(WaveGuideStructure{p},k0);
    WaveGuideStructure{p} = DelayMatrix(WaveGuideStructure{p},k0);
end

if(nbrSegments>1)
    for p=1:nbrSegments-1;
        SStep{p} = SingleStep (WaveGuideStructure, p, k0);
    end
else
    SStep{1}.S11 = zeros(WaveGuideStructure{1}.Nh+WaveGuideStructure{1}.Ne);
    SStep{1}.S12 = eye(WaveGuideStructure{1}.Nh+WaveGuideStructure{1}.Ne);
    SStep{1}.S21 = eye(WaveGuideStructure{1}.Nh+WaveGuideStructure{1}.Ne);
    SStep{1}.S22 = zeros(WaveGuideStructure{1}.Nh+WaveGuideStructure{1}.Ne);
end

Stot = Cascade(WaveGuideStructure, SStep);

% Stot = Renormalize(WaveGuideStructure,Stot);

Sf = [ [Stot.S11, Stot.S12] ; [Stot.S21, Stot.S22] ];