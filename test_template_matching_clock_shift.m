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

%% Clockshift resolution

clockShifts = 10.^(0:8);
totalClockShifts = length( clockShifts );

fastTimeEnd = logspace( -9, -3, 13 );
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
        resultsL2 = CacheResults( @GetSourceLocation, args  );
        locationsL2(:,iFastTimeEnd,jClockShift) = resultsL2.sourceLocation(:);
        dataSNR(iFastTimeEnd,jClockShift) = resultsL2.dataSNR(1);
    end
end

figure
DistanceL2 = @(x,y) sqrt( squeeze( sum( (x-y).^2 ) ) );
loglog( fastTimeEnd, DistanceL2( ...
    locationsL2, ...
    repmat( sourcePosition, [1 totalFastTimeEnds totalClockShifts] ) ), ...
    '-o', 'MarkerFaceColor', 'auto' )
grid on
xlabel( 'Clock shift [Hz]' );
ylabel( 'Location error [m]' );
xlim( minmax( clockShifts ) )

