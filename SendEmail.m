function [commandStatusOut, commandResultOut] = SendEmail( recipient, subject, body )
% SendEmail( to, subject, body ) sends an email using the UNIX mail
% command. The system must be configured so that 'mail' works in the
% command line.
%
% Example:
%   SendEmail( 'oleg.poliannikov@gmail.com', ...
%              'Send Email', ...
%              'This routine is alwesome!' );
%
% See also:
%   SENDMAIL

% Copyright 2013 Oleg V. Poliannikov (oleg.poliannikov@gmail.com)
% $Revision: 1.0.0.0 $  $Date: 2013/02/25 22:58:00 $

STATUS_FAIL = -1;
statusRequested = nargout > 0;
resultRequested = nargout > 1;

isInputValid = ischar( recipient ) ...
    && ischar( subject ) ...
    && ischar( body );

if isInputValid
    systemCommand = FormEmailCommand( recipient, subject, body );
    [commandStatus, commandResult] = system( systemCommand );
else
    commandStatus = STATUS_FAIL;
    commandResult = 'Email: Invalid input';
end

if statusRequested
    commandStatusOut = commandStatus;
end
if resultRequested
    commandResultOut = commandResult;
end

end

function command = FormEmailCommand( recipient, subject, body )

command = sprintf( 'echo "%s" | mail -s "%s" %s', body, subject, recipient );

end