function result = IsEqualSize( varargin )

sizes = cellfun( @size, varargin, 'UniformOutput', false );
result = isequal( sizes{:} );

end