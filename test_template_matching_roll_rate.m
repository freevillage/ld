%% DOA problem using a 2D array at a fixed location
%
% Set up a problem with a single source and a stationary array.
totalArrayElements = [20 20];
sourceFrequency = 300e6;
sourcePosition = [ 0 ; 0 ; 0 ];
c = physconst('LightSpeed');
wavelength = c / sourceFrequency;
elementSpacing = wavelength/2 * [1 1];
initialArrayPosition = [ -400; 0; 3000 ];
GetArrayPosition = @(t) initialArrayPosition;
GetSourcePosition = @(t) sourcePosition;
GetRotation = @(t) eye(3);
%sigmaNoise = 1e1;

SetDefaultFigureProperties


%% Effect of roll
rollRate = logspace( -2, 3, 6 );
totalRollRates = length( rollRate );

fastTimeEnd = logspace( -9, -4, 11 );
totalFastTimeEnds = length( fastTimeEnd );

GetArrayPosition = @(t) initialArrayPosition;

locationsL2 = nan( 3, totalFastTimeEnds, totalRollRates );
dataSNR = nan( totalFastTimeEnds, totalRollRates );

parfor jFastTimeEnd = 1 : totalFastTimeEnds
    for iRoll = 1 : totalRollRates
        args = { ...
            'SigmaNoise', 1e-15, ...
            'SlowTimeEnd', 0, ...
            'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'ArrayPositionFcn', GetArrayPosition, ...
            'RotationFcn', @(t) RotationMatrix( 2*pi*rollRate(iRoll) * t, 0, 0 )
            };
        resultsL2 = CacheResults( @GetSourceLocation, args  );
        locationsL2(:,jFastTimeEnd,iRoll) = resultsL2.sourceLocation(:);
        dataSNR(jFastTimeEnd,iRoll) = resultsL2.dataSNR(1);
    end
end

figure
loglog( fastTimeEnd, DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalRollRates] ) ), ...
    '-o', 'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Roll rate [Hz]' );
ylabel( 'Location error [m]' );
xlim( minmax( rollRate ) )

