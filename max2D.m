function [ rowMax, colMax, valueMax ] = max2D( matrix )

[ valueMax, indexMax ] = max( matrix(:) );
[ rowMax, colMax ] = ind2sub( size( matrix ), indexMax );

end