function [halt] = DumpError( Error )
% Writes to standard output the errors
%
% [IN]
% Error = Error structure
%
% [OUT]
% halt = vale 1 se c'è un errore fatale

halt = 0;

if(isfield(Error,'fatal'))
    disp(Error.fatal);
    halt = 1;
end

if(isfield(Error,'warning'))
    for i=1:length(Error.warning)
        disp(Error.warning{i});
    end
end

if(isfield(Error,'info'))
    for i=1:length(Error.info)
        disp(Error.info{i});
    end
end
