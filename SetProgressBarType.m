function SetProgressBarType( Type )

global GLOBAL__PROGRESS__BAR__TYPE

if( ~ischar( Type ) )
    error( 'SetProgressBarType:InputNotString', ...
           'Input parameter must be a straing' );
end

switch( Type )
    % ... allowed types
    case { 'Graphics', 'Text', 'None' }
        GLOBAL__PROGRESS__BAR__TYPE = Type;
    % ... not allowed types
    otherwise
        error( 'SetProgressBarType:InvalidInput', ...
               'Input parameters must equal None, Text or Graphics' );
end

end % of function SetProgressBarType