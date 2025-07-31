function SingleS = ExtractSingleS(Sf,Sinfo,outPort,inPort, m,n)


myModes = [ (length(Sinfo{outPort}.mh)+length(Sinfo{outPort}.me)), ...
    (length(Sinfo{inPort}.nh)+length(Sinfo{inPort}.ne)) ];
S = ExtractPortS(Sf, myModes, outPort,inPort);

SingleS = S(n+1,1);

