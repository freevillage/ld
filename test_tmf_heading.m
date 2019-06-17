% DOA problem using a 2D array at a fixed location
%
% Set up a problem with a single source and a stationary array.
totalArrayElements = [11 11];
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


%% Heading error resolution

rollShifts =  logspace( -5, 0, 11 );
%rollShifts = [ pi/4 pi/4];
totalRollShifts = length( rollShifts );

fastTimeEnd = logspace( -8, -4, 9 );
totalFastTimeEnds = length( fastTimeEnd );

locationsL2 = nan( 3, totalFastTimeEnds, totalRollShifts );
dataSNR = nan( totalFastTimeEnds, totalRollShifts );

for iFastTimeEnd = 1 : totalFastTimeEnds
    for jRollShift = 1 : totalRollShifts
        args = { ...
            'SigmaNoise', 1e-15, ...
            'SourceClockShift', 0, ...
            'RotationFcn', @(t) RotationMatrix( 0, 0, 0 ), ...
            'RotationAssumedFcn', @(t) RotationMatrix( rollShifts(jRollShift), 0, 0 ), ...
            'FastTimeEnd', fastTimeEnd(iFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ArrayPositionFcn', GetArrayPosition ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
        locationsL2(:,iFastTimeEnd,jRollShift) = resultsL2.sourceLocation(:);
        dataSNR(iFastTimeEnd,jRollShift) = resultsL2.dataSNR(1);
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors = DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalRollShifts] ) );

%%
figure

loglog( fastTimeEnd, locationErrors, ...
    '-o', ...
    'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
pbaspect( [4 3 1] )

legendRollError = arrayfun( @num2str, rollShifts, 'UniformOutput', false );
rollErrorLegend = legend( legendRollError{:}, 'Location', 'EastOutside' );
title( rollErrorLegend, 'Roll error [rad]' );

xlim( minmax( fastTimeEnd ) )
