function smoothColumns = SmoothColumns( matrix, varargin )

assert( ismatrix( matrix ) );
totalCols = size( matrix, 2 );

smoothColumns = nan( size( matrix ) );

for iCol = 1 : totalCols
    smoothColumns(:,iCol) = smooth( matrix(:,iCol), varargin{:} );
end


end