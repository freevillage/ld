function Result = StringToLogical( String )

switch( String )
    case { 'on', 'true' }
        Result = true;
    case { 'off', 'false' }
        Result = false;
    otherwise
        error( 'Cannot convert. Unrecognizable string' );
end

end % of conversion of string to logical