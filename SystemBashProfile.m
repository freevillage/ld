function [status, result] = SystemBashProfile( command, varargin )

input = inputParser;
input.CaseSensitive = true;
input.KeepUnmatched = true;
input.addOptional( 'Echo', false, @IsLogicalScalar );
input.parse( varargin{:} );

completeCall =  [ 'source ~/.bash_profile; ' command ];

if input.Results.Echo
    [status, result] = system( completeCall, '-echo' );
else
    [status, result] = system( completeCall );
end

end