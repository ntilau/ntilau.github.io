DH = [DH{1} zeros(13) ; zeros(13) DH{2}];
MH = [MH{1}; MH{2}];
DE = DE{1};
ME = [ME{1} ME{2}];

E=inv(DH)*MH;
H=inv(DE)*ME;

step{1}=WaveGuideStructure{1};
step{2} = WaveGuideStructure_2;
Sn{1}.S11 = inv(eye(step{1}.Nh+step{1}.Ne)+H*E) * (eye(step{1}.Nh+step{1}.Ne)-H*E); %S11
Sn{1}.S12 = 2*inv(eye(step{1}.Nh+step{1}.Ne)+H*E)*H; %S13
Sn{1}.S21 = E*(eye(step{1}.Nh+step{1}.Ne)+Sn{1}.S11); %S31
Sn{1}.S22 = Sn{1}.S12*E - eye((step{2}.Nh+step{2}.Ne)); %S33

Sn{1}.S11

step{1} = WaveGuideStructure{2};
step{2} = WaveGuideStructure_2;
Sn{2}.S11 = inv(eye(step{1}.Nh+step{1}.Ne)+H*E) * (eye(step{1}.Nh+step{1}.Ne)-H*E); %S22
Sn{2}.S12 = 2*inv(eye(step{1}.Nh+step{1}.Ne)+H*E)*H; %S23
Sn{2}.S21 = E*(eye(step{1}.Nh+step{1}.Ne)+Sn{1}.S11); %S32
Sn{2}.S22 = Sn{1}.S12*E - eye((step{2}.Nh+step{2}.Ne)); %S33

%Sn{1}.S22 - Sn{2}.S22

step{1} = WaveGuideStructure{1};
step{2} = WaveGuideStructure{2};
Sc.S11 = inv(eye(step{1}.Nh+step{1}.Ne)+H*E) * (eye(step{1}.Nh+step{1}.Ne)-H*E); %S11
Sc.S12 = 2*inv(eye(step{1}.Nh+step{1}.Ne)+H*E)*H; %S12
Sc.S21 = E*(eye(step{1}.Nh+step{1}.Ne)+Sc.S11); %S21
Sc.S22 = Sc.S12*E - eye((step{2}.Nh+step{2}.Ne)); %S22