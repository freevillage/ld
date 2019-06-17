%% Load data
% Load data recorded at two different altitudes: 300 and 3000
altitude1 = 3000;
altitudeString1 = num2str( altitude1 );

altitude2 = 300000;
altitudeString2 = num2str( altitude2 );

temp = load( [ 'data', altitudeString1 ] );
d1 = temp.recordedData;
r1 = squeeze( d1( 1, 1, :, 1 ) );

temp = load( [ 'data', altitudeString2 ] );
d2 = temp.recordedData;
r2 = squeeze( d2( 1, 1, :, 1 ) );

figure( 'Name', 'Absolute values' );
subplot( 2, 1, 1 )
plot( abs( r1 ) )
title( ['Recorded amplitude at ', altitudeString1] )

subplot( 2, 1, 2 )
plot( abs( r2 ) )
title(  ['Recorded amplitude at ', altitudeString2] )

figure( 'Name', 'Phase angles' );
subplot( 2, 1, 1 )
plot( angle( r1 ) )
title(  ['Recorded phase at ', altitudeString1] )

subplot( 2, 1, 2 )
plot( angle( r2 ) )
title(  ['Recorded phase at ', altitudeString2] )

%% Normalize phase
% DOA estimation depends on the phase so let us extract the phases and
% "normalize" them by subtracting the phase at the array center. This
% does not affect DOAs
%
% 
% Observe the effect of the difference in curvature 

phase1 = wrapToPi( angle( r1 ) );
phase1 = phase1 - phase1(  (length(r1)+1)/2 );

phase2 = wrapToPi( angle( r2 ) );
phase2 = phase2 - phase2( (length(r2)+1)/2 );

figure( 'Name', 'Normalized phase angles' );
subplot( 2, 1, 1 )
plot( phase1 )
title( ['Normalized phase at ', altitudeString1] )

subplot( 2, 1, 2 )
plot( phase2 )
title( ['Normalized phase at ', altitudeString2] )

figure( 'Name', 'Phase difference' )
plot( wrapToPi( phase2 - phase1 ) )
title( 'Normalized phases difference' )

%% DOA error analysis
% Finally, let us estimate DOAs and look at the errors

doaEstimated1 = DirectionOfArrival( r1, 3e8, 1 / (length(r1) - 1) );
doaEstimated2 = DirectionOfArrival( r2, 3e8, 1 / (length(r2) - 1) );
doaTrue = atan( 400 / 3000 );

doaError1 = abs( doaTrue - doaEstimated1 )
doaError2 = abs( doaTrue - doaEstimated2 )