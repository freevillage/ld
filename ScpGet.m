function [status, result] = ScpGet ( hostName, userName, password, remoteFilename, localPath )

command = sprintf( 'scp %s@%s:%s %s', ...
    userName, hostName, remoteFilename, localPath );

[status, result] = SystemBashProfile( command, 'Echo', true );

end
