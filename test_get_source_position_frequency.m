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

%% Fasttime window resolution
fastTimeEnd = logspace( -6, -3, 13 );
totalFastTimeEnds = length( fastTimeEnd );

sigmaNoise = logspace( -13, -3, 11 );
totalSigmas = length( sigmaNoise );

locationsL2 = nan( 3, totalFastTimeEnds, totalSigmas );
dataSNR = nan( totalFastTimeEnds, totalSigmas );

parfor iFastTimeEnd = 1 : totalFastTimeEnds
    for jSigma = 1 : totalSigmas
        args = { ...
            'SigmaNoise', sigmaNoise(jSigma), ...
            'SourceClockShift', 0, ...
            'FastTimeEnd', fastTimeEnd(iFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ArrayPositionFcn', GetArrayPosition ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
        locationsL2(:,iFastTimeEnd,jSigma) = resultsL2.sourceLocation(:);
        dataSNR(iFastTimeEnd,jSigma) = resultsL2.dataSNR(1);
    end
end

% figure
% DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
% loglog( fastTimeEnd, DistanceL2( ...
%     locationsL2, ...
%     repmat( sourcePosition, [1 totalFastTimeEnds totalSigmas] ) ), ...
%     '-o', 'MarkerFaceColor', 'auto' )
% grid on
% ylabel( 'Location error [m]' );
% xlabel( 'Fast time interval [s]' );
% xlim( minmax( fastTimeEnd ) )
% legendSigma = arrayfun( @num2str, sigmaNoise, 'UniformOutput', false );
% sigmaLegend = legend( legendSigma{:}, 'Location', 'EastOutside' );
% title( sigmaLegend, '\sigma_{noise}' );

%% Clockshift resolution

clockShifts = 10.^(0:7);
totalClockShifts = length( clockShifts );

fastTimeEnd = logspace( -8, -4, 5 );
totalFastTimeEnds = length( fastTimeEnd );

locationsL2 = nan( 3, totalFastTimeEnds, totalClockShifts );
dataSNR = nan( totalFastTimeEnds, totalClockShifts );

parfor iFastTimeEnd = 1 : totalFastTimeEnds
    for jClockShift = 1 : totalClockShifts
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

% figure
% DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
% semilogy( clockShifts, DistanceL2( locationsL2, repmat( sourcePosition, [1 totalFastTimeEnds totalClockShifts] ) ), '-o', 'MarkerFaceColor', 'auto' )
% grid on
% xlabel( 'Clock shift [Hz]' );
% ylabel( 'Location error [m]' );
% 
% legendTime = arrayfun( @num2str, fastTimeEnd, 'UniformOutput', false );
% timeLegend = legend( legendTime{:}, 'Location', 'EastOutside' );
% title( timeLegend, '\tau' );

%xlim( minmax( clockShifts ) )


%% Velocity resolution

aspectAngle = pi/2;
velocity = 10 .^ (-2:12);
%velocity = 10^5;
totalVelocities = length( velocity );

fastTimeEnd = logspace( -9, -4, 11 );
totalFastTimeEnds = length( fastTimeEnd );

radialDirection = NormalizeVector( initialArrayPosition - sourcePosition );
flightDirection = RotationMatrix3D( [0, 1, 0], aspectAngle ) * radialDirection;

locationsL2 = nan( 3, totalFastTimeEnds, totalVelocities );
dataSNR = nan( totalFastTimeEnds, totalVelocities );

parfor jFastTimeEnd = 1 : totalFastTimeEnds
    for iVelocity = 1 : totalVelocities
        GetArrayPosition = @(t) initialArrayPosition + velocity(iVelocity) * t * flightDirection;
        args = { ...
            'SigmaNoise', 1e-15, ...
            'SlowTimeEnd', 0, ...
            'FastTimeEnd', fastTimeEnd(jFastTimeEnd), ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ArrayPositionFcn', GetArrayPosition ...
            };
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
        locationsL2(:,jFastTimeEnd,iVelocity) = resultsL2.sourceLocation(:);
        dataSNR(jFastTimeEnd,iVelocity) = resultsL2.dataSNR(1);
    end
end

% figure
% loglog( fastTimeEnd, DistanceL2( ...
%     locationsL2, ...
%     repmat( sourcePosition, [1 totalFastTimeEnds totalVelocities] ) ), ...
%     '-o', 'MarkerFaceColor', 'auto' )
% grid on
% xlabel( 'Array speed [m/s]' );
% ylabel( 'Location error [m]' );
% xlim( minmax( velocity ) )

%% Total array elements resolution

totalElements = 5:25;
totalArraySizes = length( totalElements );

fastTimeEnd = logspace( -9, -4, 11 );
totalFastTimeEnds = length( fastTimeEnd );

GetArrayPosition = @(t) initialArrayPosition;

locationsL2 = nan( 3, totalFastTimeEnds, totalArraySizes );
dataSNR = nan( totalFastTimeEnds, totalArraySizes );

parfor jFastTimeEnd = 1 : totalFastTimeEnds
    for iSize = 1 : totalArraySizes
        args = { ...
            'SigmaNoise', 1e-15, ...
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

% figure
% loglog( fastTimeEnd, DistanceL2( ...
%     locationsL2, ...
%     repmat( sourcePosition, [1 totalFastTimeEnds totalArraySizes] ) ), ...
%     '-o', 'MarkerFaceColor', 'auto' )
% grid on
% xlabel( 'Array size [elements]' );
% ylabel( 'Location error [m]' );
% xlim( minmax( totalElements ) )


%% Effect of roll
rollRate = logspace( -2, 3, 6 );
totalRollRates = length( rollRate );

fastTimeEnd = logspace( -8, -4, 9 );
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
        resultsL2 = CacheResults( @GetSourceLocationByFrequencyTemplateMatching, args  );
        locationsL2(:,jFastTimeEnd,iRoll) = resultsL2.sourceLocation(:);
        dataSNR(jFastTimeEnd,iRoll) = resultsL2.dataSNR(1);
    end
end

DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
locationErrors = DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalRollRates] ) );

figure
loglog( fastTimeEnd, locationErrors', ...
    '-o', 'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Roll rate [Hz]' );
ylabel( 'Location error [m]' );
%xlim( minmax( rollRate ) )

