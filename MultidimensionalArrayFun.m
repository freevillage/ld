function result = MultidimensionalArrayFun( f, array )

sizeFx = size( f( array(1) ) );
sizeArray = size( array );
sizeResult = squeeze( [ sizeFx sizeArray ] );    

% resultArrayVectorized = arrayfun( f, ToColumn( array ), 'UniformOutput', false );

arrayVectorized = ToColumn( array );
resultArrayVectorized = cell( length( arrayVectorized ), 1 );
parfor i = 1 : length( arrayVectorized )
    resultArrayVectorized{i} = f( arrayVectorized(i) );
end

result = squeeze( reshape( ...
    cat( length( sizeFx ) + 1, resultArrayVectorized{:} ), ...
    sizeResult ...
    ) );

end