function filename = uniqueString()

prefix = '/scratch1/local/tmp/';
tmpExtension = '.tmp';
currentTime = num2str( now * 10000 );
randomInteger = sprintf( '%.0f', 1e5 * rand );

filename = strcat( prefix, currentTime, randomInteger, tmpExtension );

end % of function uniqueString
