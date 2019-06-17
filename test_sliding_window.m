function error = test_sliding_window( windowSize, sigmaNoise )
%% DOA problem using a 2D array at a fixed location
%
% Set up a problem with a single source and a stationary array.
totalArrayElements = [20 20];
sourceFrequency = 300e6;
sourcePosition = [ 0 ; 0 ; 0 ];
c = physconst('LightSpeed');
wavelength = c / sourceFrequency;
elementSpacing = wavelength/2 * [1 1];
GetArrayPosition = @(t) [ -400; 500; 300 ];
GetSourcePosition = @(t) sourcePosition;
GetRotation = @(t) eye(3);
%%
%
% Previously, location using a 2D array was performed by estimating DOAs
% using each row and column, and averaging those angles to yield two
% angles. Now we will split the array to subarrays by setting up an
% elementary "sliding window experiment". The idea is that each subarray
% will estimate a slightly different angle, and, instead of averaging them,
% we would feed them directly into location estimation inversion.
% Estimating a source location, and not just DOAs, would mean estimating
% the range, too.
%
% Conceptually, there is nothing new here. A "sliding window experiment" is
% just a smaller array "flying" inside the original one. We have already
% shown experiments with locating towers using a flying array. 

%windowSize = 5;
totalWindowsX = totalArrayElements(1) + 1 - windowSize;
totalWindowsY = totalArrayElements(2) + 1 - windowSize;

resultsDOA = cell( totalWindowsX, totalWindowsY );
windowLocation = nan( 3, totalWindowsX, totalWindowsY );

ura = UniformRectangularArray( ...
            (totalArrayElements-1) .* elementSpacing, ...
            totalArrayElements, ...
            GetArrayPosition(0), ...
            GetRotation(0) );

for iWin = 1 : totalWindowsX
    for jWin = 1 : totalWindowsY
        args = { ...
            'SigmaNoise', sigmaNoise, ...
            'FastTimeEnd', 1e-6, ...
            'SourcePositionFcn', GetSourcePosition, ...
            'SourceFrequency', sourceFrequency, ...
            'ElementSpacing', elementSpacing, ...
            'TotalElements', totalArrayElements, ...
            'ActiveArrayWindow', { iWin : iWin+windowSize-1, jWin : jWin+windowSize-1 }, ...
            'ArrayPositionFcn', GetArrayPosition ...
            };
        resultsDOA{iWin,jWin} = CacheResults( @GetDirectionsOfArrival, args  );
        %results{iWin,jWin} = GetDirectionsOfArrival( args{:} );
        
        windowLocation(:,iWin,jWin) = mean( reshape( ura(:,iWin:iWin+windowSize-1,jWin:jWin+windowSize-1), [3 windowSize*windowSize] ), 2 );
    end
end

thetaEstimated = nan( 2, totalWindowsX, totalWindowsY );
thetaTrue = nan( 2, totalWindowsX, totalWindowsY );

% %%
% args = { ...
%             'SigmaNoise', sigmaNoise, ...
%             'FastTimeEnd', 1e-6, ...
%             'SourcePositionFcn', GetSourcePosition, ...
%             'SourceFrequency', sourceFrequency, ...
%             'ElementSpacing', elementSpacing, ...
%             'TotalElements', totalArrayElements, ...
%             'ArrayPositionFcn', GetArrayPosition ...
%             };
% resultsL2{iWin,jWin} = CacheResults( @GetSourceLocation, args  );

%%
%
% For each window (2D subarray), we estimate two angles
for iWin = 1 : totalWindowsX
    for jWin = 1 : totalWindowsY
        thetaEstimated(:,iWin,jWin) = resultsDOA{iWin,jWin}.anglesEstimated(:,1);
        thetaTrue(:,iWin,jWin) = resultsDOA{iWin,jWin}.anglesTrue(:,1,1);
    end
end
%%
%
% We then convert estimated angles to the location
thetas = reshape( thetaEstimated, [2 totalWindowsX*totalWindowsY]);
windowPositions = reshape( windowLocation, [3 totalWindowsX*totalWindowsY] );
sourcePositionEst = Doa2Pos( ...
    windowPositions, ... 
    zeros( totalWindowsX*totalWindowsY, 1 ), ...
    zeros( totalWindowsX*totalWindowsY, 1 ), ...
    zeros( totalWindowsX*totalWindowsY, 1 ), ...
    thetas( 1, : ), ...
    thetas( 2, : ) ...
    );

%%
%
% I do not show any pictures here. Instead I simply look at the distance
% between the true and estimated source positions.
error = norm( sourcePosition - sourcePositionEst );
%fprintf( 'Location error: %g\n', norm( sourcePosition - sourcePositionEst ) );

end