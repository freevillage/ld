figure

location = [0;0;1e-3];

subplot( 2, 3, 1 )
absData = abs( squeeze( recordedDataSingleFreq1 ) );
imagesc( absData )
colorbar
title( 'Recorded data' )

subplot( 2, 3, 2 )
absTemplate = abs( squeeze( UnnormalizedTemplate( location )) );
imagesc( absTemplate )
colorbar
title( 'Template' )

subplot( 2, 3, 3 )
imagesc( absData - absTemplate )
colorbar
title( 'Difference' )


subplot( 2, 3, 4 )
angleData = angle( squeeze( recordedDataSingleFreq1 ) );
imagesc( angleData )
colorbar
title( 'Recorded data' )

subplot( 2, 3, 5 )
angleTemplate = angle( squeeze( UnnormalizedTemplate( location )) );
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

subplot( 1, 3, 1 );
costs = arrayfun( @(x) CostFunction2( [x;0;0] ), xss );
semilogx( xss, costs );
xlabel( 'x error [m]' )
title( 'Template matching cost' )
xlim( [1e-6 power(10,-5)] )

% subplot( 2, 3, 4 )
% costsRefined = arrayfun( @(x) ExtendedCostFunction( [x;0;0;input.Results.SourceFrequency] ), xss );
% loglog( xss, costsRefined )
% xlabel( 'x error [m]' );
% title( 'Amplitude matching cost (post-TM)' )
% xlim( [1e-6 power(10,-4)] )


subplot( 1, 3, 2 );
costs = arrayfun( @(x) CostFunction2( [0;x;0] ), xss );
semilogx( xss, costs );
xlabel( 'y error [m]' )
title( 'Template matching cost' )
xlim( [1e-6 power(10,-5)] )

% subplot( 2, 3, 5 )
% costsRefined = arrayfun( @(x) ExtendedCostFunction( [0;x;0;input.Results.SourceFrequency] ), xss );
% loglog( xss, costsRefined )
% xlabel( 'y error [m]' );
% title( 'Amplitude matching cost (post-TM)' )
% xlim( [1e-6 power(10,-4)] )

subplot( 1, 3, 3 );
costs = arrayfun( @(x) CostFunction2( [0;0;x] ), xss );
semilogx( xss, costs );
xlabel( 'z error [m]' )
title( 'Template matching cost' )
xlim( [1e-4 power(10,-1)] )

% subplot( 2, 3, 6 )
% costsRefined = arrayfun( @(x) ExtendedCostFunction( [0;0;x;input.Results.SourceFrequency] ), xss );
% loglog( xss, costsRefined )
% xlabel( 'z error [m]' );
% title( 'Amplitude matching cost (post-TM)' )
% xlim( [1e-6 power(10,-1)] )
