figure

location = [yfEstimated(1:2);0];
f = input.Results.SourceFrequency;

subplot( 2, 3, 1 )
absData = abs( ( squeeze( recordedDataSingleFreq1 ) ) );
imagesc( absData )
colorbar
title( 'Recorded data' )

subplot( 2, 3, 2 )
absTemplate = abs( ( squeeze( UnnormalizedExtendedTemplate( location, f )) ) );
imagesc( absTemplate )
colorbar
title( 'Template' )

subplot( 2, 3, 3 )
imagesc( absData - absTemplate )
colorbar
title( 'Difference' )


subplot( 2, 3, 4 )
angleData = angle( ( squeeze( recordedDataSingleFreq1 ) ) );
imagesc( angleData )
colorbar
title( 'Recorded data' )

subplot( 2, 3, 5 )
angleTemplate = angle( ( squeeze( UnnormalizedExtendedTemplate( location, f )) ) );
imagesc( angleTemplate )
colorbar
title( 'Template' )

subplot( 2, 3, 6 )
imagesc( angleData - angleTemplate )
colorbar
title( 'Difference' )
suptitle( sprintf( 'Abs (top), Angle (bottom) at %.1e m from true location', location(1) ) )

figure
xss = logspace( -20, 0, 1000 );
costs = arrayfun( @(x) CostFunction( [x;0] ), xss );
costsRefined = arrayfun( @(x) ExtendedCostFunction( [x;0;input.Results.SourceFrequency] ), xss );
subplot( 2, 1, 1 );
semilogx( xss, costs );
xlabel( 'Location error [m]' )
title( 'Template matching cost' )
xlim( [1e-8 power(10,-4)] )

subplot( 2, 1, 2 )
loglog( xss, costsRefined )
xlabel( 'Location error [m]' );
title( 'Amplitude matching cost (post-TM)' )
xlim( [1e-8 power(10,-4)] )
