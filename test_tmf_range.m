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


%% Total array elements resolution

ranges = [300 3000 30000];
totalRanges = length( ranges );

fastTimeEnd = logspace( -8, -4, 5 );
totalFastTimeEnds = length( fastTimeEnd );

locationsL2 = nan( 3, totalFastTimeEnds, totalRanges );
dataSNR = nan( totalFastTimeEnds, totalRanges );

parfor jFastTimeEnd = 1 : totalFastTimeEnds
    for iRange = 1 : totalRanges
        GetArrayPosition = @(t) ranges(iRange) * NormalizeVector(initialArrayPosition);
        args = { ...
            'SigmaNoise', 1e-100, ...
            'SlowTimeEnd', 0, ...
            'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'ArrayPositionFcn', GetArrayPosition ...
            'FourierTransformLength', 2^24, ...
            'FourierWindowFunction', @blackman, ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
        locationsL2(:,jFastTimeEnd,iRange) = resultsL2.sourceLocation(:);
        dataSNR(jFastTimeEnd,iRange) = resultsL2.dataSNR(1);
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors =  DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalRanges] ) );

%%

figure
loglog( fastTimeEnd, locationErrors, ...
    '-o', ...
    'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1] )

legendSize = arrayfun( @num2str, ranges, 'UniformOutput', false );
sizeLegend = legend( legendSize{:}, 'Location', 'EastOutside' );
title( sizeLegend, 'Range [m]' );



