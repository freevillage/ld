% DOA problem using a 2D array at a fixed location
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


%% Total array elements resolution

totalElements = 3:4:30;
totalArraySizes = length( totalElements );

fastTimeEnd = logspace( -8, -4, 9 );
totalFastTimeEnds = length( fastTimeEnd );

GetArrayPosition = @(t) initialArrayPosition;

locationsL2 = nan( 3, totalFastTimeEnds, totalArraySizes );
dataSNR = nan( totalFastTimeEnds, totalArraySizes );

parfor jFastTimeEnd = 1 : totalFastTimeEnds
    for iSize = 1 : totalArraySizes
        args = { ...
            'SigmaNoise', 1e-30, ...
            'SlowTimeEnd', 0, ...
            'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalElements(iSize)*[1 1], ...
            'ArrayPositionFcn', GetArrayPosition ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
        locationsL2(:,jFastTimeEnd,iSize) = resultsL2.sourceLocation(:);
        dataSNR(jFastTimeEnd,iSize) = resultsL2.dataSNR(1);
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors =  DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalArraySizes] ) );

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

legendSize = arrayfun( @num2str, totalElements, 'UniformOutput', false );
sizeLegend = legend( legendSize{:}, 'Location', 'EastOutside' );
title( sizeLegend, 'Number of elements' );



