function string = LogicalToYesNo( value )

assert( IsLogicalScalar( value ), ...
    'LogicalToYesNo:WrongInput', ...
    'Input must be a logical scalar (true or false)' );

if value == true
    string = 'y';
else % value == false
    string = 'n';
end 

end