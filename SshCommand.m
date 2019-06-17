function [status, result] = SshCommand ( hostName, userName, password, remoteCommand )

localCommand = sprintf( 'ssh %s@%s "bash --login -c "%s" --"', ...
    userName, hostName, remoteCommand );

[status, result] = SystemBashProfile( localCommand, 'Echo', true );

end
