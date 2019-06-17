function Value = GetInputValue( Input, VariableName, VariableType, DefaultValue )

% If the variable is not found in the input then the value is set to the
% DefaultValue. If the DefaultValue is not specified, it is NaN
if( nargin < 4 )
    DefaultValue = nan;
end

Value = DefaultValue;

% If the variable type is not specified do nothing. Otherwise we will check
% that the value conforms to the class specified by the string VariableType
if( nargin < 3 )
    VariableType = nan;
end



% Checking if the input is proper
if( ~iscell( Input ) )
    error( 'GetInputValue:InputNotCell', ...
        'Input must be a cell array' );
end

TotalInputs = length( Input );

% It is assumed that input contains names of parameters followed by their
% values, e.g., f( x, 'Position', 0 )
for InputNumber = 1 : TotalInputs - 1
    
    % Take another input data
    CurrentInput = Input{ InputNumber };
    
    % Check that it is a string
    if( ischar( CurrentInput ) )
        
        % If the input equals the desired variable's name... 
        if( strcmp( CurrentInput, VariableName ) )
            % ... then what follows is the value
            Value = Input{ InputNumber + 1 };
            
            % Check its type if required
            if( ~isnan( VariableType ) )
                
                % If the class is wrong assume that the value is not found
                if( ~isa( Value, VariableType ) )
                    Value = DefaultValue;
                    
                % If the class is right then do nothing
                end
            end
            
            % The end
            return;
        end
        
    end
end
    
    

end