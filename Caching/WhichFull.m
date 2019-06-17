function directory = WhichFull( cmd )

whichOutput = which( cmd );

if WhichSaysBuiltIn( whichOutput )
    directory = BetweenParentheses( whichOutput );
else
    directory = whichOutput;
end

end

function isBuiltIn = WhichSaysBuiltIn( whichOutput )

isBuiltIn = strcmp( whichOutput(1:8), 'built-in' );

end

function substring = BetweenParentheses( string )

substring = regexp( string, '(?<=\()\S+(?=\))', 'match', 'once' );

end