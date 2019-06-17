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


%% Velocity resolution


% fastTimeEnd = logspace( -8, -6, 3 );
fastTimeEnd = 10.^(-8:-4);
totalFastTimeEnds = length( fastTimeEnd );

seeds = 8419;
seeds = randi(10000, [1 1]);
%seeds = randi( 1000, [20 1], 'distributed' );
seeds = 12345;
% seeds = randi( 10000 );
totalSeeds = length( seeds );

arrayFractionPerturbed = 10 .^ (-5:0);
arrayFractionPerturbed = 10 .^ (-5:0);

totalArrayPerturbations = length( arrayFractionPerturbed );

sourcePhases = linspace( 0, pi, totalSeeds );

locationsL2 = nan( 3, totalArrayPerturbations, totalFastTimeEnds, totalSeeds );
locationsCoarseL2 = nan( 3, totalArrayPerturbations, totalFastTimeEnds, totalSeeds );
dataSNR = nan( totalArrayPerturbations, totalFastTimeEnds, totalSeeds );



for kArrayPer = 1 : totalArrayPerturbations
    thisFraction = arrayFractionPerturbed(kArrayPer);
    arrayPerturbation = struct( 'i', 1, 'j', 1, 'dx', thisFraction, 'dy', thisFraction );
    for jFastTimeEnd = 1 : totalFastTimeEnds
        for iSeed = 1 : totalSeeds
            args = { ...
                'ArrayPerturbation', arrayPerturbation, ...
                'SigmaNoise', 1e-103, ...
                'FastTimeSamplingFrequency', 1e9, ...
                'SlowTimeEnd', 0, ...
                'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
                'SourcePositionFcn', GetSourcePosition, ...
                'SourceFrequency', sourceFrequency, ...
                'SourcePhase', pi/3, ...
                'ElementSpacing', elementSpacing, ...
                'TotalElements', totalArrayElements, ...
                'ArrayPositionFcn', GetArrayPosition, ...
                'FourierTransformLength', 2^24, ...
                'FourierWindowFunction', @hann, ...
                'RandomNumberGenerator', { seeds(iSeed) } ...
                };
            resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatchingPerturbed, args  );
            locationsL2(:,kArrayPer,jFastTimeEnd,iSeed) = resultsL2.sourceLocation(:);
            locationsCoarseL2(:,kArrayPer,jFastTimeEnd,iSeed) = resultsL2.sourceLocationCoarse(:);
            dataSNR(kArrayPer,jFastTimeEnd,iSeed) = resultsL2.dataSNR(1);
        end
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors = DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalArrayPerturbations totalFastTimeEnds totalSeeds ] ) );

locationCoarseErrors = DistanceL2( ...
    locationsCoarseL2, ...
    repmat( sourcePosition, [1 totalArrayPerturbations totalFastTimeEnds totalSeeds ] ) );

meanLocationErrors = mean( locationErrors, 4 );
meanLocationCoarseErrors = mean( locationCoarseErrors, 4 );

%%

figure
loglog( ...
    fastTimeEnd, (meanLocationErrors), ...
    '-o', 'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Fast time recording window [s]' );
ylabel( 'Location error [m]' );
xlim( minmax( fastTimeEnd ) )
pbaspect( [4 3 1] )
axis tight
legendItems = arrayfun( @(d) strrep(sprintf('10^{%d}', d),'10^{0}','1'), antennaPerturbOrder, 'UniformOutput', false);
antennaPertLegend = legend( legendItems{:}, 'Location', 'EastOutside' );
title( antennaPertLegend, 'Antenna shift [m]' )

% legendVelocity = arrayfun( @num2str, velocity, 'UniformOutput', false );
% velocityLegend = legend( legendVelocity{:}, 'Location', 'EastOutside' );
% title( velocityLegend, 'Array velocity [m/s]' );
