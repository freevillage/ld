function [ flag ] = IsLayered( array )
%ISLAYERED returns true if the array varies only along the last dimension
%   and false otherwise

lastDim = ndims( array );
profiles = num2cell( array, lastDim );
flag = isequal( profiles{:} );


end

