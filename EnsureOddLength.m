function yNew = EnsureOddLength( y )
warning( 'Function outdated. Use TrimToOddLength.m instead' );

if( IsOdd( length( y ) ) )
    yNew = y;
else
    yNew = y( 1 : end-1 );
end
    

end