function yNew = EnsureOddLength( y )

if( IsOdd( length( y ) ) )
    yNew = y;
else
    yNew = y( 1 : end-1 );
end
    

end