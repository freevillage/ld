function I = RiemannIntegral( x, f, A, B )

Beginning = find( x > A, 1, 'first' );
End = find( x < B, 1, 'last' );
Interval = Beginning : End;

I = trapz( x( Interval ), f( Interval ) );

end