function [status, result] = ScpPut ( hostName, userName, password, localFile, remotePath )

command = sprintf( 'scp %s %s@%s:%s', ...
    localFile, userName, hostName, remotePath );

[status, result] = SystemBashProfile( command, 'Echo', true );

end
