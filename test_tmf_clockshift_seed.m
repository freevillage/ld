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

clockShifts = 10.^(1:7);
totalClockShifts = length( clockShifts );

fastTimeEnd = logspace( -8, -4, 5 );
totalFastTimeEnds = length( fastTimeEnd );

seeds = ToColumn( 2:2 );
totalSeeds = length( seeds );

sourcePhases = linspace( 0, pi, totalSeeds );

locationsL2 = nan( 3, totalFastTimeEnds, totalClockShifts, totalSeeds );
locationsCoarseL2 = nan( 3, totalFastTimeEnds, totalClockShifts, totalSeeds );
dataSNR = nan( totalFastTimeEnds, totalClockShifts, totalSeeds );

parfor iFastTimeEnd = 1 : totalFastTimeEnds
    for jClockShift = 1 : totalClockShifts
        for kSeed = 1 : totalSeeds
            args = { ...
                'SigmaNoise', 1e-100, ...
                'SourcePhase', 0, ...
                'SourceClockShift', clockShifts(jClockShift), ...
                'FastTimeEnd', fastTimeEnd(iFastTimeEnd), ...
                'SourcePositionFcn', GetSourcePosition, ...
                'SourceFrequency', sourceFrequency, ...
                'ElementSpacing', elementSpacing, ...
                'TotalElements', totalArrayElements, ...
                'ArrayPositionFcn', GetArrayPosition, ...
                'FourierTransformLength', 2^24, ...
                'FourierWindowFunction', @blackman, ...
                'RandomNumberGenerator', { seeds(kSeed) } ...
                };
            resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
            locationsL2(:,iFastTimeEnd,jClockShift,kSeed) = resultsL2.sourceLocation(:);
            locationsCoarseL2(:,iFastTimeEnd,jClockShift,kSeed) = resultsL2.sourceLocationCoarse(:);
            dataSNR(iFastTimeEnd,jClockShift,kSeed) = resultsL2.dataSNR(1);
        end
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors = DistanceL2( locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalClockShifts totalSeeds] ) );
%%

meanLocationErrors = mean( locationErrors, 3 );

figure

loglog( fastTimeEnd, meanLocationErrors' , ...
    '-o', ...
    'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
pbaspect( [4 3 1] )
axis tight

% Num2StrExp = @(x) strrep( num2str(x, '%.0e'), 'e+0', 'e' );
Num2StrExp =  @(x) sprintf( '10^%d', round(x) );

% legendClockShift = arrayfun( Num2StrExp, clockShifts, 'UniformOutput', false );
legendClockShift = arrayfun( Num2StrExp, log10(clockShifts ), 'UniformOutput', false );

clockShiftLegend = legend( legendClockShift{:}, 'Location', 'EastOutside' );
title( clockShiftLegend, 'Clock shift [Hz]' );

xlim( minmax( fastTimeEnd ) )
