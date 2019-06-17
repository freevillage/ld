function checksum = MessageDigestFile( filename )
%MessageDigestFile  Message-digest fingerprint (checksum) for a file
%
%   s = MessageDigestFile( filename )  computes the checksum for a file if
%   the file exists; otherwise it returns an empty array

% Author: Oleg V. Poliannikov 5/23/2014

[isError, checksum] = system( [ 'md5 -q ', filename ] );

if isError
    checksum = [];
else
    % md5 ends EOL, which needs to be removed
    checksum = checksum(1:end-1);
end

end