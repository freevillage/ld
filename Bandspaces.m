function space = Bandspaces( ranges, Npts, scalingCoeff )

if nargin < 3, scalingCoeff = 0; end

Nbands = size( ranges, 1 );
Nptsband = floor( Npts/Nbands );

bands = cell( 1, Nbands );

for i = 1 : Nbands
    newRange = MinMaxExpanded( ranges(i,:), scalingCoeff );
    bands{i} = linspace( newRange(1), newRange(2), Nptsband );
end

space = unique( sort( horzcat( bands{:} ) ) );

end