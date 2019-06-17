function result = IsEqualLength( varargin )

lengths = cellfun( @length, varargin, 'UniformOutput', false );
result = isequal( lengths{:} );

end