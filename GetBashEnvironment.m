function variableValue = GetBashEnvironment( variableName, configFileName )

if nargin < 2
    configFileName = '~/.bash_profile';
end

systemCall = [ 'source ', configFileName, '; echo $', variableName ];
[ ~, variableValue ] = system( systemCall );

variableValue = strtrim( variableValue );

end