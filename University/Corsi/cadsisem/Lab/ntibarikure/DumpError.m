function [halt] = DumpError( pre, Error )
% Writes to standard output the errors
% V 1.0 - Oct. 2008
% V 2.0 - 21 Nov. 2008 - ported to MultiPortDevices
% ------------------------------------------------------------------------
% [IN]
% Error = Error structure
%
% [OUT]
% halt = vale 1 se c'è un errore fatale

halt = 0;

if (isfield(Error,'AlreadyDumped'))

    if(isfield(Error,'fatal'))
        halt = 1;
    end

else

    if(isfield(Error,'fatal'))
        disp([pre,Error.fatal]);
        halt = 1;
    end

    if(isfield(Error,'warning'))
        for i=1:length(Error.warning)
            disp([pre,Error.warning{i}]);
        end
    end

    if(isfield(Error,'info'))
        for i=1:length(Error.info)
            disp([pre,Error.info{i}]);
        end
    end
end