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


%% Clockshift resolution

clockShifts = 10.^(2:7);
totalClockShifts = length( clockShifts );

fastTimeEnd = logspace( -8, -4, 17 );
totalFastTimeEnds = length( fastTimeEnd );

locationsL2 = nan( 3, totalFastTimeEnds, totalClockShifts );
dataSNR = nan( totalFastTimeEnds, totalClockShifts );

for iFastTimeEnd = 1 : totalFastTimeEnds
    parfor jClockShift = 1 : totalClockShifts
        args = { ...
            'SigmaNoise', 1e-9, ...
            'SourceClockShift', clockShifts(jClockShift), ...
            'FastTimeEnd', fastTimeEnd(iFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ArrayPositionFcn', GetArrayPosition ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
        locationsL2(:,iFastTimeEnd,jClockShift) = resultsL2.sourceLocation(:);
        dataSNR(iFastTimeEnd,jClockShift) = resultsL2.dataSNR(1);
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors = DistanceL2( locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalClockShifts] ) );
%%

figure

loglog( fastTimeEnd, locationErrors' , ...
    '-o', ...
    'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
pbaspect( [4 3 1] )

Num2StrExp = @(x) strrep( num2str(x, '%.0e'), 'e+0', 'e' );

legendClockShift = arrayfun( Num2StrExp, clockShifts, 'UniformOutput', false );
clockShiftLegend = legend( legendClockShift{:}, 'Location', 'EastOutside' );
title( clockShiftLegend, 'Clock shift [Hz]' );

xlim( minmax( fastTimeEnd ) )
