%% Geolocation of a moving platform using three sources
%
%% Sources description
% 
%
clear all
close all force
addpath( genpath( '.' ) )
isGraphicsEnabled = true;

sourcePosition = [ ...
    800, 400, -800 ; ...
    -50, 800, 0 ; ...
    0, 0, 0 ];
freqCarrier = 300 * 10^6; % Carrier frequency
freqMin = [305, 310, 315] * 10^6; % minimum possible frequency
freqMax = [305, 310, 315] * 10^6; % maximum possible frequency
totalSources = length( freqMin );
totalSourceComponents = 1; % number of monochromatic components in a source
c = LightSpeed;

clockShiftAverage = 0;
%clockShiftAverage = 4500;

freqSource  = nan( totalSourceComponents, totalSources );
phaseSource = nan( totalSourceComponents, totalSources );

for iSource = 1 : totalSources
    freqSource(:,iSource) = sort( RandomUniform( freqMin(iSource), freqMax(iSource), [totalSourceComponents 1] ) ); % source frequencies
    phaseSource(:,iSource) = RandomUniform( 0, 2*pi, [totalSourceComponents 1] ); % source phases
end

amplitudeSource = ones( totalSourceComponents, totalSources ); % amplitudes

freqCentral = mean( freqSource, 1 );

sourceAssumed = cell( totalSources, 1 );
sourceTrue = cell( totalSources, 1 );

for iSource = 1 : totalSources
    sourceAssumed{iSource} = PolychromaticSource( ...
        sourcePosition(:,iSource), ...
        amplitudeSource(:,iSource), ...
        freqSource(:,iSource), ...
        phaseSource(iSource) );
    
    sourceTrue{iSource} = PolychromaticSource( ...
        sourcePosition(:,iSource), ...
        amplitudeSource(:,iSource), ...
        freqSource(:,iSource) + clockShiftAverage, ...
        phaseSource(iSource) );
end

sourceAssumed = [sourceAssumed{:}];
sourceTrue = [sourceTrue{:}];

%% Array geometry
%
% 
%
arrayLengthX = 1;
arrayLengthY = 1;
totalAntennasXFine = 15;
totalAntennasYFine = 17;

totalAntennasXCoarse = 3;
totalAntennasYCoarse = 3;

arraySpacingXFine = arrayLengthX/(totalAntennasXFine-1);
arraySpacingYFine = arrayLengthY/(totalAntennasYFine-1);

arraySpacingXCoarse = arrayLengthX / ( totalAntennasXCoarse-1 );
arraySpacingYCoarse = arrayLengthY / ( totalAntennasYCoarse-1 );

arrayFine = UniformRectangularAntennaArray( ...
    [ totalAntennasXFine totalAntennasYFine ], ...
    [ arraySpacingXFine arraySpacingYFine ] );
arrayCoarse = UniformRectangularAntennaArray( ...
    [ totalAntennasXCoarse totalAntennasYCoarse ], ...
    [ arraySpacingXCoarse arraySpacingYCoarse ] );

%% Display arrays used for DOA and FDOA
%
% Ideally we would like to use an array with many antennas and record for
% as long as necessary. Because of time and memory constraints, we use a
% _coarse_ array (few antennas) to do FDOA (and hence record for longer
% fast-time, and we use a _fine_ array (many antennas) to record for short
% fast-time periods for DOAs estimation. The "coarse" array is a subset of
% the "fine" array, so everything is compatible.

if isGraphicsEnabled
    disp( arrayCoarse )
    disp( arrayFine )
end
                                    
%% Description of platform motion
%
% 
%
initialArrayPosition = [-400; 0; 200];
arrayHorzSpeed = 40; % m/s

GetArrayPosition = @(t) bsxfun( @plus, initialArrayPosition, arrayHorzSpeed * [ t; sin(t)/100; cos(t)/100 ] );
GetRotationAboutX = @(t) 0. * cos(t);
GetRotationAboutY = @(t) 0. * sin(2*t);
GetRotationAboutZ = @(t) 0. * cos(4*t);

movingUraFine = MovingURA( arrayFine, ...
    GetArrayPosition, ...
    GetRotationAboutX, ...
    GetRotationAboutY, ...
    GetRotationAboutZ ...
    );
movingUraCoarse = MovingURA( arrayCoarse, ...
    GetArrayPosition, ...
    GetRotationAboutX, ...
    GetRotationAboutY, ...
    GetRotationAboutZ ...
    );

%% Discrete times of data recording

slowTimeBeg = 0;
slowTimeEnd = 15;
slowSamplingFrequency = 10; % Hz
slowTime = slowTimeBeg : 1/slowSamplingFrequency : slowTimeEnd;
totalSlowTimes = length( slowTime );

fastSamplingFrequency = 8 * max( freqCentral );
fastSamplingPeriod = 1 / fastSamplingFrequency;
fastRecordingTimeLong = 100000 * fastSamplingPeriod;
fastDelayLong = 0 : fastSamplingPeriod : fastRecordingTimeLong;
totalFastTimesLong = length( fastDelayLong );


downsampledFrequency = 8 * max( freqCentral-freqCarrier );
downsampledPeriod = 1/downsampledFrequency;
downsampledDelayLong = 0 : downsampledPeriod : fastRecordingTimeLong;
totalDownsampledTimesLong = length( downsampledDelayLong );

fastRecordingTimeShort = 40 * fastSamplingPeriod;
fastDelayShort = 0 : fastSamplingPeriod : fastRecordingTimeShort;
totalFastTimesShort = length( fastDelayShort );

downsampledDelayShort = 0 : downsampledPeriod : fastRecordingTimeShort;
totalDownsampledTimesShort = length( downsampledDelayShort );

fastTimeLong  = bsxfun( @plus, ToColumn( fastDelayLong ),  ToRow( slowTime ) );
fastTimeShort = bsxfun( @plus, ToColumn( fastDelayShort ), ToRow( slowTime ) );

downsampledTimeLong  = bsxfun( @plus, ToColumn( downsampledDelayLong ), ToRow( slowTime ) );
downsampledTimeShort = bsxfun( @plus, ToColumn( downsampledDelayShort), ToRow( slowTime ) ); 

% arrayPositionFine   = MultidimensionalArrayFun( movingUraFine.positionFcn,   fastTimeShort );
% arrayPositionCoarse = MultidimensionalArrayFun( movingUraCoarse.positionFcn, fastTimeLong  );
% 

GetArrayPositionFast = @(ura,t) reshape( ura.positionFcn( ToRow(t) ), [3 size(t)] ); 

arrayPositionFine   = GetArrayPositionFast( movingUraFine,   fastTimeShort );
arrayPositionCoarse = GetArrayPositionFast( movingUraCoarse, fastTimeLong ); 

% arrayPositionFineDownsampled = MultidimensionalArrayFun( movingUraFine.positionFcn,   downsampledTimeShort );
% arrayPositionCoarseDownsampled = MultidimensionalArrayFun( movingUraCoarse.positionFcn, downsampledTimeLong  );

arrayPositionFineDownsampled   = GetArrayPositionFast( movingUraFine,   downsampledTimeShort );
arrayPositionCoarseDownsampled = GetArrayPositionFast( movingUraCoarse, downsampledTimeLong );


receiverPositionFine = movingUraFine.GetAntennaPositions( fastTimeShort );
receiverPositionCoarse = movingUraCoarse.GetAntennaPositions( fastTimeLong );

receiverPositionFineDownsammpled = movingUraFine.GetAntennaPositions( downsampledTimeShort );
receiverPositionCoarseDownsampled = movingUraCoarse.GetAntennaPositions( downsampledTimeLong );

assert( isequal( size( receiverPositionFine ), ...
    [ 3 movingUraFine.array.totalCols movingUraFine.array.totalRows totalFastTimesShort totalSlowTimes ] ), ...
    'Unexpected size of receiverPositionFine' )
assert( isequal( size( receiverPositionCoarse ), ...
    [ 3 movingUraCoarse.array.totalCols movingUraCoarse.array.totalRows totalFastTimesLong totalSlowTimes ] ), ...
    'Unexpected size of receiverPositionFine' )


%% Display geometry
%
% 
%
if isGraphicsEnabled
    figure, hold on
    Plot3dData( [sourceAssumed.position], 'rp', 'MarkerFaceColor', 'r', 'MarkerSize', 15 );
    Plot3dData( arrayPositionFine(:,1,:), 'g-' );
    Plot3dData( arrayPositionFine(:,1,1), 'go', 'MarkerFaceColor', 'g' );
    Plot3dData( arrayPositionFine(:,1,end), 'go', 'MarkerFaceColor', 'r' );
    view( [-13 30] )
    if totalSources > 1
        sourceLocationsLegend = 'Source locations';
    else
        sourceLocationsLegend = 'Source location';
    end
    legend( sourceLocationsLegend, 'Platform path', 'Starting point', 'End point', ...
        'Location', 'SouthOutside', ...
        'Orientation', 'Horizontal' )
    grid on
    xlabel( 'Easting [m]' ), ylabel( 'Northing [m]' ), zlabel( 'Altitude [m]' )
    title( 'Experiment geometry' )
    axis equal
    hold off
end

%% Simulating recorded data
%
% 
%
cleanDataFine = arrayfun( ...
    @(s) RecordedDataUra( receiverPositionFine, s, fastTimeShort ), ...
    sourceTrue, ...
    'UniformOutput', false );
cleanDataCoarse = arrayfun( ...
    @(s) RecordedDataUra( receiverPositionCoarse, s, fastTimeLong ), ...
    sourceTrue, ...
    'UniformOutput', false );

%noiseSnr = 1;
%noiseSnr = 10;
%noiseSnr = 20;
%noiseSnr = 41;
%noiseSnr = 60;
%noiseSnr = 80;
noiseSnr = 100;
areRecordedDataNoisy = true;

noisyDataFine   = cleanDataFine;
noisyDataCoarse = cleanDataCoarse;
noisyDataFine2   = cleanDataFine;
noisyDataCoarse2 = cleanDataCoarse;

for iSource = 1 : totalSources
    for ks = 1 : totalSlowTimes
        noisyDataFine{iSource}(:,:,:,ks) = AddWhiteGaussianNoise( ...
            cleanDataFine{iSource}(:,:,:,ks), ...
            noiseSnr, 'measured' );
        noisyDataFine2{iSource}(:,:,:,ks) = AddWhiteGaussianNoise( ...
            cleanDataFine{iSource}(:,:,:,ks), ...
            noiseSnr, 'measured' );
        
        noisyDataCoarse{iSource}(:,:,:,ks) = AddWhiteGaussianNoise( ...
            cleanDataCoarse{iSource}(:,:,:,ks), ...
            noiseSnr, 'measured' );
        noisyDataCoarse2{iSource}(:,:,:,ks) = AddWhiteGaussianNoise( ...
            cleanDataCoarse{iSource}(:,:,:,ks), ...
            noiseSnr, 'measured' );
    end
end

if areRecordedDataNoisy
    recordedDataFine   = noisyDataFine;
    recordedDataCoarse = noisyDataCoarse;
    
    recordedDataFine2   = noisyDataFine2;
    recordedDataCoarse2 = noisyDataCoarse2;
else
    recordedDataFine   = cleanDataFine;
    recordedDataCoarse = cleanDataCoarse;
    
    recordedDataFine2   = cleanDataFine;
    recordedDataCoarse2 = cleanDataCoarse;
end


% Demodulation
recordedDataFineDemodulated = recordedDataFine;
recordedDataCoarseDemodulated = recordedDataCoarse;
recordedDataFine2Demodulated = recordedDataFine2;
recordedDataCoarse2Demodulated = recordedDataCoarse2;
% 
% DemodulateRealSignal = @(signal) pmdemod( signal, ...
%     freqCarrier, fastSamplingFrequency, pi/2  );

downsampleRatio = fastSamplingFrequency / downsampledFrequency;

downsampledDataFine    = cellfun( @(x)nan( totalAntennasXFine, totalAntennasYFine, totalDownsampledTimesShort, totalSlowTimes ), num2cell(1:totalSources), 'UniformOutput', false );
downsampledDataFine2   = cellfun( @(x)nan( totalAntennasXFine, totalAntennasYFine, totalDownsampledTimesShort, totalSlowTimes ), num2cell(1:totalSources), 'UniformOutput', false );

downsampledDataCoarse =  cellfun( @(x)nan( totalAntennasXCoarse, totalAntennasYCoarse, totalDownsampledTimesLong, totalSlowTimes ), num2cell(1:totalSources), 'UniformOutput', false );
downsampledDataCoarse2 = cellfun( @(x)nan( totalAntennasXCoarse, totalAntennasYCoarse, totalDownsampledTimesLong, totalSlowTimes ), num2cell(1:totalSources), 'UniformOutput', false );


for iSource = 1 : totalSources
    for ks = 1 : totalSlowTimes
        for ix = 1 : totalAntennasXCoarse
            for jy = 1 : totalAntennasYCoarse
                downsampledDataCoarse{iSource}(ix,jy,:,ks)  = DemodulateSignal( ToColumn(recordedDataCoarse{iSource}(ix,jy,:,ks)), fastTimeLong(:,ks), freqCarrier,downsampleRatio );
                downsampledDataCoarse2{iSource}(ix,jy,:,ks) = DemodulateSignal( ToColumn(recordedDataCoarse2{iSource}(ix,jy,:,ks)), fastTimeLong(:,ks), freqCarrier,downsampleRatio );
            end
        end
        
        for ix = 1 : totalAntennasXFine
            for jy = 1 : totalAntennasYFine               
                downsampledDataFine{iSource}(ix,jy,:,ks)  = DemodulateSignal( ToColumn(recordedDataFine{iSource}(ix,jy,:,ks)),  fastTimeShort(:,ks), freqCarrier,downsampleRatio );
                downsampledDataFine2{iSource}(ix,jy,:,ks) = DemodulateSignal( ToColumn(recordedDataFine2{iSource}(ix,jy,:,ks)),  fastTimeShort(:,ks), freqCarrier,downsampleRatio );
            end
        end
        
    end
end

downsampledSumCoarse  = zeros( size( downsampledDataCoarse{1}  ) );
downsampledSumCoarse2 = zeros( size( downsampledDataCoarse2{1} ) );

downsampledSumFine  = zeros( size( downsampledDataFine{1} ) );
downsampledSumFine2 = zeros( size( downsampledDataFine2{1} ) );

for iSource = 1 : totalSources
    downsampledSumCoarse  = downsampledSumCoarse  + downsampledDataCoarse{iSource};
    downsampledSumCoarse2 = downsampledSumCoarse2 + downsampledDataCoarse2{iSource};
    
    downsampledSumFine  = downsampledSumFine  + downsampledDataFine{iSource};
    downsampledSumFine2 = downsampledSumFine2 + downsampledDataFine2{iSource};
end


%% Plot sample gathers

% figure
% for iSource = 1 : totalSources
%     subplot( 1, totalSources, iSource );
%     contour( abs(recordedDataFine{iSource}(:,:,1,1) )', 'ShowText', 'on' )
%     axis( [ 1 arrayFine.totalCols 1 arrayFine.totalRows ] )
%     set( gca, ...
%         'XTick', 1:arrayFine.totalCols, ...
%         'YTick', 1:arrayFine.totalRows ...
%         );
%     xlabel( 'Antenna column' ), ylabel( 'Antenna row' )
%     title( sprintf( 'Source #%d', iSource ) )
% end
% suptitle( 'Sample recorded signal amplitude' )

if isGraphicsEnabled
%     figure
%     for iSource = 1 : totalSources
%         sampleTrace = squeeze( recordedDataCoarse{iSource}(1,1,:,1) );
%         sampleCleanTrace = squeeze( cleanDataCoarse{iSource}(1,1,:,1) );
%         subplot( totalSources, 1, iSource )
%         plot( ...
%             1e6 * fastTimeLong(:,1), sampleTrace(:), ...
%             1e6 * fastTimeLong(:,1), sampleCleanTrace(:) ...
%             )
%         xlabel( 'Fast time [\mus]' )
%         title( sprintf( 'Source #%d', iSource ) )
%         xlim( [0 1 ] )
%         legend( 'Recorded', 'Clean' )
%     end
%     
%     superTitle = sprintf( 'Amplitudes of sample noisy traces (SNR=%.0fdB, long)', ...
%         noiseSnr );
%     suptitle( superTitle )
    
figure
sampleTrace = squeeze( downsampledSumCoarse(1,1,:,1) );
plot( ...
    1e6 * downsampledTimeLong(:,1), real(sampleTrace(:)), ...
    1e6 * downsampledTimeLong(:,1), imag(sampleTrace(:)) ...
    )
xlabel( 'Fast time [\mus]' )
title( sprintf( 'Source #%d', iSource ) )
xlim( [0 1 ] )
legend( 'Re', 'Im' )
superTitle = sprintf( 'downsampled amplitudes (SNR=%.0fdB)', ...
    noiseSnr );
suptitle( superTitle )

    
end

%% Estimating directions of arrival using correlation
%
% 
%

%
% True angles
%
anglesTrue = nan( [2 size( fastTimeShort ), totalSources] );
anglesTrueDownsampled = nan( [2 size( downsampledTimeShort ), totalSources ] );

for iSource = 1 : totalSources
    anglesTrue(:,:,:,iSource) = MultidimensionalArrayFun( ...
        @(time) TrueAngles( movingUraFine, sourceAssumed(iSource), time ), ...
        fastTimeShort ...
        );
end

for iSource = 1 : totalSources
    anglesTrueDownsampled(:,:,:,iSource) = MultidimensionalArrayFun( ...
        @(time) TrueAngles( movingUraFine, sourceAssumed(iSource), time ), ...
        downsampledTimeShort ...
        );
end

%% Estimate angles
% 
%
if isGraphicsEnabled, progressBar = waitbar( 0, 'Estimating DOAs...' ); end
% 
% anglesEstimated = nan( 2, totalSlowTimes, totalSources );
% anglesEstimated2 = nan( 2, totalSlowTimes, totalSources );

anglesEstimatedDownsampled  = nan( 2, totalSources, totalSlowTimes );
anglesEstimated2Downsampled = nan( 2, totalSources, totalSlowTimes );


%for iSource = 1 : totalSources
      %  if isGraphicsEnabled, waitbar( 0, progressBar, sprintf( 'Estimating DOAs to source #%d', iSource ) ); end

%     recordedDataIsource = recordedDataFine{iSource};
%     recordedDataIsource2 = recordedDataFine2{iSource};
%     
%     downsampledDataIsource = downsampledDataFine{iSource};
%     downsampledDataIsource2 = downsampledDataFine2{iSource};
    
    for ks = 1 : totalSlowTimes
%         recordedDataIsourceTrimmed = recordedDataIsource(:,:,1,ks);
%         recordedDataIsourceTrimmed2 = recordedDataIsource2(:,:,1,ks);
%         
%         downsampledDataIsourceTrimmed = downsampledDataIsource(:,:,1,ks);
%         downsampledDataIsource2Trimmed = downsampledDataIsource2(:,:,1,ks);
        
%         anglesEstimated(:,ks,iSource) = DirectionsOfArrivalUra( ...
%             downsampledSumFine(:,:,1,ks), ...
%             mean(freqCentral), ...
%             [arraySpacingXFine arraySpacingYFine], ...
%             'Method', 'MatrixPencil', ...
%             'TotalFrequencies', totalSourceComponents );
        
        anglesEstimatedDownsampled(:,:,ks) = DirectionsOfArrivalUra( ...
            downsampledSumFine(:,:,1,ks), ...
            mean(freqCentral), ...
            [arraySpacingXFine arraySpacingYFine], ...
            'Method', 'MatrixPencil', ...
            'TotalFrequencies', totalSources );
        
%         anglesEstimated2(:,ks,iSource) = DirectionsOfArrivalUra( ...
%             recordedDataIsourceTrimmed2, ...
%             freqCentral(iSource), ...
%             [arraySpacingXFine arraySpacingYFine], ...
%             'Method', 'CorrelationSinglePhase', ...
%             'TotalFrequencies', totalSourceComponents );
        
        anglesEstimated2Downsampled(:,:,ks) = DirectionsOfArrivalUra( ...
            downsampledSumFine(:,:,1,ks), ...
            mean(freqCentral), ...
            [arraySpacingXFine arraySpacingYFine], ...
            'Method', 'MatrixPencil', ...
            'TotalFrequencies', totalSources );
        
        if isGraphicsEnabled, waitbar( ks/totalSlowTimes, progressBar ); end
    end
% end

if isGraphicsEnabled, delete( progressBar ); end

%% Compare true angles with estimated ones
% 
%
% anglesTrueX = ( squeeze( anglesTrue(1,1,:,:) ) );
% anglesTrueY = ( squeeze( anglesTrue(2,1,:,:) ) );
% 
% if isGraphicsEnabled
%     figure
%     subplot( 2, 2, 1 ), hold on
%     plot( ToColumn(slowTime), radtodeg( squeeze( anglesEstimated(1,:,:) ) ) );
%     plot( ToColumn(slowTime), radtodeg( anglesTrueX ), ...
%         '--', ...
%         'LineWidth', 3 );
%     xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
%     title( 'Estimated vs true DOAs' )
%     LegendWithLaTeX( [ ...
%         arrayfun( @(is) [ '$\widehat{\phi_{x,', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) ...
%         arrayfun( @(is) [ '$\phi_{x,', num2str(is), '}$'], 1:3, 'UniformOutput', false ), ...
%         ] );
%     
%     subplot( 2, 2, 2 ), hold on
%     plot( ToColumn(slowTime), radtodeg( squeeze( anglesEstimated(2,:,:) ) ) );
%     plot( ToColumn( slowTime ), radtodeg( anglesTrueY ), ...
%         '--', ...
%         'LineWidth', 3 );
%     xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
%     title( 'Estimated vs true DOAs' )
%     LegendWithLaTeX( [ ...
%         arrayfun( @(is) [ '$\widehat{\phi_{y,', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) ...
%         arrayfun( @(is) [ '$\phi_{y,', num2str(is), '}$'], 1:3, 'UniformOutput', false ), ...
%         ] );
%     
%     subplot( 2, 2, 3 )
%     plot( ToColumn(slowTime), radtodeg( minus( anglesTrueX, squeeze( anglesEstimated(1,:,:) ) ) ) )
%     xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
%     LegendWithLaTeX( arrayfun( @(is) [ '$\phi_{x,', num2str(is), '}-\widehat{\phi_{x,', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) );
%     title( 'Estimation errors' )
%     
%     subplot( 2, 2, 4 )
%     plot( ToColumn(slowTime), radtodeg( minus( anglesTrueY, squeeze( anglesEstimated(2,:,:) ) ) ) )
%     xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
%     LegendWithLaTeX( arrayfun( @(is) [ '$\phi_{y,', num2str(is), '}-\widehat{\phi_{y,', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) );
%     title( 'Estimation errors' )
% end

%% Compare true angles with estimated ones (DOWNSAMPLED)
% 
%
anglesTrueX = ( squeeze( anglesTrue(1,1,:,:) ) );
anglesTrueY = ( squeeze( anglesTrue(2,1,:,:) ) );

if isGraphicsEnabled
    figure
    subplot( 2, 2, 1 ), hold on
    plot( ToColumn(slowTime), radtodeg( squeeze( anglesEstimatedDownsampled(1,:,:) ) ) );
    plot( ToColumn(slowTime), radtodeg( anglesTrueX ), ...
        '--', ...
        'LineWidth', 3 );
    xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
    title( 'Estimated vs true DOAs' )
    LegendWithLaTeX( [ ...
        arrayfun( @(is) [ '$\widehat{\phi_{x,', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) ...
        arrayfun( @(is) [ '$\phi_{x,', num2str(is), '}$'], 1:3, 'UniformOutput', false ), ...
        ] );
    
    subplot( 2, 2, 2 ), hold on
    plot( ToColumn(slowTime), radtodeg( squeeze( anglesEstimatedDownsampled(2,:,:) ) ) );
    plot( ToColumn( slowTime ), radtodeg( anglesTrueY ), ...
        '--', ...
        'LineWidth', 3 );
    xlabel( 'Time [s]' ), ylabel( 'Angle [deg]' )
    title( 'Estimated vs true DOAs' )
    LegendWithLaTeX( [ ...
        arrayfun( @(is) [ '$\widehat{\phi_{y,', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) ...
        arrayfun( @(is) [ '$\phi_{y,', num2str(is), '}$'], 1:3, 'UniformOutput', false ), ...
        ] );
    
    subplot( 2, 2, 3 )
    plot( ToColumn(slowTime), radtodeg( minus( transpose(anglesTrueX), squeeze( anglesEstimatedDownsampled(1,:,:) ) ) ) )
    xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
    LegendWithLaTeX( arrayfun( @(is) [ '$\phi_{x,', num2str(is), '}-\widehat{\phi_{x,', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) );
    title( 'Estimation errors' )
    
    subplot( 2, 2, 4 )
    plot( ToColumn(slowTime), radtodeg( minus( transpose(anglesTrueY), squeeze( anglesEstimatedDownsampled(2,:,:) ) ) ) )
    xlabel( 'Time [s]' ), ylabel( 'Error [deg]' )
    LegendWithLaTeX( arrayfun( @(is) [ '$\phi_{y,', num2str(is), '}-\widehat{\phi_{y,', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) );
    title( 'Estimation errors' )
end

%% Calculate tower location based on estimated DOAs
%
% 
%

sourcePositionEstimated = nan( 3, totalSources );
for is = 1 : totalSources
    sourcePositionEstimated(:,is) = Doa2Pos( ...
        arrayPositionFineDownsampled(:,1,:), ...
        movingUraFine.rotationXFcn(slowTime), ...
        movingUraFine.rotationYFcn(slowTime), ...
        movingUraFine.rotationZFcn(slowTime), ...
        anglesEstimatedDownsampled(1,:,is), anglesEstimatedDownsampled(2,:,is) ...
        );
end

sourcePositionEstimationError = ColumnNorm( sourcePositionEstimated - [sourceAssumed.position] );

if isGraphicsEnabled
    figure, hold on
    Plot3dData(sourcePositionEstimated, 'rp', 'MarkerFaceColor', 'r' );
    Plot3dData([sourceAssumed.position], 'k.', 'MarkerFaceColor', 'k' );
    
    for is = 1 : totalSources
        text( sourceAssumed(is).position(1) + 20 , sourceAssumed(is).position(2), sourceAssumed(is).position(3), ...
            [ '\epsilon_{', num2str(is), '}=', num2str( sourcePositionEstimationError(is), '%.1e' ) ] );
    end
    
    Plot3dData( arrayPositionFineDownsampled(:,1,:), 'g-' );
    view( [-25 30] )
    xlabel( 'Easting [m]' ), ylabel( 'Northing [m]' ), zlabel( 'Altitude [m]' );
    title( 'Errors of reconstruction of source locations' )
    hold off
end

%% Calculate platform true radial speeds

receiverPositionSlow = squeeze( receiverPositionCoarse(:,:,:,1,:) );
velocityReceiver = nan( size( receiverPositionSlow ) );
velocityTowardsTower = nan( [ size( receiverPositionSlow ), totalSources ] );
signSpeedTrue = nan( movingUraCoarse.array.totalCols, movingUraCoarse.array.totalRows, totalSlowTimes, totalSources );

for jy = 1 : movingUraCoarse.array.totalRows
    for ix = 1 : movingUraCoarse.array.totalCols
        for mDim = 1 : 3
            for kSlow = 1 : totalSlowTimes
                velocityReceiver(mDim,ix,jy,kSlow) = mean( gradient( ...
                    squeeze( receiverPositionCoarse( mDim, ix, jy, :,kSlow ) ), ...
                    fastSamplingPeriod ) );
            end
        end
    end
end

sourcePositionMatrices = cell( totalSources, 1 );
for iSource = 1 : totalSources
    sourcePositionMatrices{iSource} = repmat( ToColumn( sourcePositionEstimated(:,iSource) ), ...
        [ 1 movingUraCoarse.array.totalCols movingUraCoarse.array.totalRows totalSlowTimes ] ...
    );
end

directionTowardsTower = cell( totalSources, 1 );
for iSource = 1 : totalSources
    directionTowardsTower{iSource} = sourcePositionMatrices{iSource} - receiverPositionSlow;
end

for iSource = 1 : totalSources
    for jy = 1 : movingUraCoarse.array.totalRows
        for ix = 1 : movingUraCoarse.array.totalCols
            for kSlow = 1 : totalSlowTimes
                unitDirection = NormalizeVector( directionTowardsTower{iSource}(:,ix,jy,kSlow) );
                velocity = velocityReceiver(:,ix,jy,kSlow);
                radialVelocityAmplitude = dot( velocity, unitDirection );
                velocityTowardsTower(:,ix,jy,kSlow,iSource) = radialVelocityAmplitude * unitDirection;
                signSpeedTrue(ix,jy,kSlow,iSource) = sign( radialVelocityAmplitude );
            end
        end
    end
end

speedTrue = sqrt( squeeze( sum( velocityTowardsTower.^2, 1 ) ) );
speedTrue = speedTrue .* signSpeedTrue;

%% Estimate Doppler shifts

% freqsEstimated = nan( ...
%     movingUraCoarse.array.totalRows, ...
%     movingUraCoarse.array.totalCols, ...
%     totalSourceComponents, ...
%     totalSlowTimes, ...
%     totalSources );
% 
% if isGraphicsEnabled, progressBarSources = waitbar( 0, 'Processing sources...' ); end
% 
% for iSource = 1 : totalSources
%     recordedDataCoarseSource2 = recordedDataCoarse2{iSource};
%     %progressBarSlowtimes = waitbar( 0, 'Processing slow times...' );
%     
%     parfor kSlow = 1 : totalSlowTimes        
%         freqsEstimated(:,:,:,kSlow,iSource) = DiscreteFrequencySpectrumHertzUra( ...
%             recordedDataCoarseSource2(:,:,:,kSlow), ...
%             fastSamplingFrequency, ...
%             'TotalFrequencies', totalSources, ...
%             'Method', 'CorrelationSinglePhase' );
%         
%        % waitbar( kSlow / totalSlowTimes, progressBarSlowtimes );
%     end
%     
%    % delete( progressBarSlowtimes );
%     if isGraphicsEnabled, waitbar( iSource/totalSources, progressBarSources ); end
% end
% 
% if isGraphicsEnabled, delete( progressBarSources ); end

%% Estimate Doppler shifts (DOWNSAMPLED)

freqsEstimatedDownsampled = nan( ...
    movingUraCoarse.array.totalRows, ...
    movingUraCoarse.array.totalCols, ...
    totalSourceComponents, ...
    totalSlowTimes, ...
    totalSources );

if isGraphicsEnabled, progressBarSources = waitbar( 0, 'Processing sources...' ); end

for iSource = 1 : totalSources
    downsampledDataCoarseSource2 = downsampledDataCoarse2{iSource};
    %progressBarSlowtimes = waitbar( 0, 'Processing slow times...' );
    
    parfor kSlow = 1 : totalSlowTimes        
        freqsEstimatedDownsampled(:,:,:,kSlow,iSource) = DiscreteFrequencySpectrumHertzUra( ...
            downsampledDataCoarseSource2(:,:,:,kSlow), ...
            downsampledFrequency, ...
            'TotalFrequencies', totalSources, ...
            'Method', 'CorrelationSinglePhase' );
        
       % waitbar( kSlow / totalSlowTimes, progressBarSlowtimes );
    end
    
   % delete( progressBarSlowtimes );
    if isGraphicsEnabled, waitbar( iSource/totalSources, progressBarSources ); end
end

if isGraphicsEnabled, delete( progressBarSources ); end

%% Plot estimated frequencies (DOWNSAMPLED)
%
%
%
% 
ix = 1; jy = 1;
profilesTrue = repmat( freqSource-freqCarrier, [ totalSlowTimes, 1 ] );
profilesEstimated = squeeze( freqsEstimatedDownsampled(ix,jy,1,:,:) );

if isGraphicsEnabled
    figure, subplot( 1, 2, 1 ), hold on
    plot( slowTime, profilesEstimated/1e6 );
    plot( slowTime, profilesTrue/1e6 , ...
        '--', ...
        'LineWidth', 3 );
    xlabel( 'Slow time [s]' );
    ylabel( 'Frequency [MHz]' );
    title( 'Frequency estimated from moving array' );
    LegendWithLaTeX( [ ...
        arrayfun( @(is) [ '$\widehat{f_{', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) ...
        arrayfun( @(is) [ '$f_{', num2str(is), '}$'], 1:3, 'UniformOutput', false ), ...
        ] );
    hold off
    
    subplot( 1, 2, 2 )
    plot( slowTime, profilesEstimated - profilesTrue );
    LegendWithLaTeX( arrayfun( @(is) [ '$\widehat{f_{', num2str(is), '}}-f_{', num2str(is), '}$'], 1:3, 'UniformOutput', false ) );
    xlabel( 'Slow time [s]' )
    ylabel( 'Frequency variations [Hz]' )
    title( 'Doppler shift in the recorded signal' )
end

%% Convert frequencies to velocities
%
%
%
% 
% speedEstimated = nan( ...
%     movingUraCoarse.array.totalRows, ...
%     movingUraCoarse.array.totalCols, ...
%     totalSlowTimes, ...
%     totalSources );
% 
% for ix = 1 : movingUraCoarse.array.totalRows
%     for jy = 1 : movingUraCoarse.array.totalCols
%         for kSlow = 1 : totalSlowTimes
%             for iSource = 1 : totalSources
%                 theseFreqsEstimated = squeeze( freqsEstimated(ix,jy,:,kSlow,iSource) );
%                 theseFreqsSource = freqSource(:,iSource);
%                 speedEstimated(ix,jy,kSlow,iSource) = VelocityFromDopplerShift( ...
%                     theseFreqsSource, ...
%                     theseFreqsEstimated );
%             end
%         end
%     end
% end

%% Convert frequencies to velocities (DOWNSAMPLED)
%
%
%

speedEstimatedDownsampled = nan( ...
    movingUraCoarse.array.totalRows, ...
    movingUraCoarse.array.totalCols, ...
    totalSlowTimes, ...
    totalSources );

for ix = 1 : movingUraCoarse.array.totalRows
    for jy = 1 : movingUraCoarse.array.totalCols
        for kSlow = 1 : totalSlowTimes
            for iSource = 1 : totalSources
                theseFreqsEstimated = squeeze( freqsEstimatedDownsampled(ix,jy,:,kSlow,iSource) );
                theseFreqsSource = freqSource(:,iSource) - freqCarrier;
                speedEstimatedDownsampled(ix,jy,kSlow,iSource) = VelocityFromDopplerShift( ...
                    theseFreqsSource + freqCarrier, ...
                    theseFreqsEstimated + freqCarrier );
            end
        end
    end
end

%% Show speed estimation results
%
%
ix = 1; jy = 1;
profilesTrue = squeeze( speedTrue(ix,jy,:,:) );
profilesEstimated = squeeze( speedEstimatedDownsampled(ix,jy,:,:) );

if isGraphicsEnabled
    figure, subplot( 1, 2, 1), hold on
    plot( slowTime, profilesEstimated )
    plot( slowTime, profilesTrue, ...
        '--', ...
        'LineWidth', 3 );
    xlabel( 'Slow time [s]' );
    ylabel( 'Velocity [m/s]' );
    title( 'Radial velocity towards tower' );
    LegendWithLaTeX( [ ...
        arrayfun( @(is) [ '$\widehat{V_{', num2str(is), '}}$'], 1:3, 'UniformOutput', false ) ...
        arrayfun( @(is) [ '$V_{', num2str(is), '}$'], 1:3, 'UniformOutput', false ), ...
        ] );
    hold off
    
    subplot( 1, 2, 2 ), hold on
    plot( slowTime, profilesEstimated - profilesTrue )
    xlabel( 'Slow time [s]' )
    LegendWithLaTeX( arrayfun( @(is) [ '$\widehat{V_{', num2str(is), '}}-V_{', num2str(is), '}$'], 1:3, 'UniformOutput', false ) );
    ylabel( 'Velocity error [m/s]' )
    title( 'Velocity estimation error' )
end

%% Convert DOAs and radial velocities to platform location 
%
%
%

% sourcePositionAssumed = [source.position];
sourcePositionAssumed = sourcePositionEstimated;

Adoa = cell( totalSources, 1 );
bdoa = cell( totalSources, 1 );
Avel = cell( totalSources, 1 );
bvel = cell( totalSources, 1 );

alpha = GetRotationAboutX( slowTime );
beta  = GetRotationAboutY( slowTime );
gamma = GetRotationAboutZ( slowTime );

for iSource = 1 : totalSources
    
    thisAdoa = zeros( 2*totalSlowTimes, 3*totalSlowTimes );
    thisbdoa = zeros( 2*totalSlowTimes, 1 );
    
    thisAvel = zeros( totalSlowTimes, 3*totalSlowTimes );
    thisbvel = zeros( totalSlowTimes, 1 );
    
    for kSlow = 1 : totalSlowTimes
        theseAnglesEstimated = num2cell( anglesEstimated2(:,kSlow,iSource) );
        [n1, n2, k] = Doa2N( alpha(kSlow), beta(kSlow), gamma(kSlow), theseAnglesEstimated{:} );
        
        % Populating the DOA matrices
        thisAdoa(2*kSlow-1,3*kSlow-2:3*kSlow) = n1;
        thisAdoa(2*kSlow,  3*kSlow-2:3*kSlow) = n2;
        
        thisbdoa(2*kSlow-1) = dot( n1, sourcePositionAssumed(:,iSource) );
        thisbdoa(2*kSlow)   = dot( n2, sourcePositionAssumed(:,iSource) );
        
        % Populating the FDOA matrices
        if kSlow > 1 && kSlow < totalSlowTimes
            deltaSlowTime = slowTime(kSlow+1) - slowTime(kSlow-1);
            
            thisAvel(kSlow,3*kSlow-5:3*kSlow-3) = -k / deltaSlowTime;
            thisAvel(kSlow,3*kSlow+1:3*kSlow+3) =  k / deltaSlowTime;
            
            thisbvel(kSlow) = mean( ToColumn( speedEstimatedDownsampled(:,:,kSlow,iSource) ) );
        end
    end
    
    Adoa{iSource} = thisAdoa;
    bdoa{iSource} = thisbdoa;
    
    Avel{iSource} = thisAvel;
    bvel{iSource} = thisbvel;
    
end

Aic = eye( 3, 3*totalSlowTimes );
bic = initialArrayPosition;

A_doa = vertcat( Adoa{:}, Aic );
b_doa = vertcat( bdoa{:}, bic );

A_fdoa = vertcat( Avel{:}, Aic );
b_fdoa = vertcat( bvel{:}, bic );

A_both = vertcat( Adoa{:}, Avel{:}, Aic );
b_both = vertcat( bdoa{:}, bvel{:}, bic );

arrayPositionEstimatedDoa  = reshape( A_doa  \ b_doa,  [3 totalSlowTimes] );
arrayPositionEstimatedFdoa = reshape( A_fdoa \ b_fdoa, [3 totalSlowTimes] );
arrayPositionEstimatedBoth = reshape( A_both \ b_both, [3 totalSlowTimes] );


%% Compare estimated path with the true one
%
%
%

arrayPositionTrue = squeeze( arrayPositionFine(:,1,:) );

arrayPositionEstimationErrorDoa  = arrayPositionEstimatedDoa  - arrayPositionTrue;
arrayPositionEstimationErrorFdoa = arrayPositionEstimatedFdoa - arrayPositionTrue;
arrayPositionEstimationErrorBoth = arrayPositionEstimatedBoth - arrayPositionTrue;

% Plot DOA results only
if isGraphicsEnabled
    figure
    %subplot( 2, 1, 1 )
    hold on
    Plot3dData( arrayPositionTrue, ...
        'g-', ...
        'MarkerFaceColor', 'g' );
    Plot3dData( arrayPositionEstimatedDoa, ...
        'b-.', ...
        'LineWidth', 3, ...
        'MarkerFaceColor', 'b' );
    % Plot3dData( arrayPositionEstimatedFdoa, ...
    %     'bd-.', ...
    %     'LineWidth', 3, ...
    %     'MarkerFaceColor', 'b' );
%     Plot3dData( arrayPositionEstimatedBoth, ...
%         'r-.', ...
%         'LineWidth', 3, ...
%         'MarkerFaceColor', 'r' );
    Plot3dData( [sourceAssumed.position], 'rp', ...
        'MarkerFaceColor', 'r', ...
        'MarkerSize', 15 );
    legend( 'True', 'DOA' )
    view( [-13 30] )
    xlabel( 'Easting [m]' ), ylabel( 'Northing [m]' ), zlabel( 'Altitude [m]' )
    title( 'Platform trajectory' )
    hold off
    
%     subplot( 2, 1, 2 )
%     [hAx,hLine1,hLine2] = plotyy( [slowTime', slowTime'], [ColumnNorm( arrayPositionEstimationErrorDoa )', ColumnNorm( arrayPositionEstimationErrorBoth )'], ...
%         slowTime, ColumnNorm( arrayPositionEstimationErrorBoth ) ./ ColumnNorm( arrayPositionEstimationErrorDoa ) );
%     legend( 'DOA', 'DOA+FDOA' )
%     ylabel(hAx(1),'Error norm [m]') % left y-axis
%     ylabel(hAx(2),'DOA+FDOA/DOA error ratio') % right y-axis
%     title( 'Platform position estimation error' )
%     xlabel( 'Slow time [s]' )
    
    figure
    
    subplot( 1, 3, 1 ), hold on
    plot( slowTime, arrayPositionEstimatedDoa(1,:) - arrayPositionTrue(1,:) );
    %plot( slowTime, arrayPositionEstimatedBoth(1,:) - arrayPositionTrue(1,:) );
    xlabel( 'Slow time [s]' );
    ylabel( 'Error [m]' );
    title( 'DOA X error' );
    %legend( 'DOA', 'DOA+FDOA' );
    hold off
    
    subplot( 1, 3, 2 ), hold on
    plot( slowTime, arrayPositionEstimatedDoa(2,:) - arrayPositionTrue(2,:) );
    %plot( slowTime, arrayPositionEstimatedBoth(2,:) - arrayPositionTrue(2,:) );
    xlabel( 'Slow time [s]' );
    ylabel( 'Error [m]' );
    title( 'DOA Y error' );
    %legend( 'DOA', 'DOA+FDOA' );
    hold off
    
    subplot( 1, 3, 3 ), hold on
    plot( slowTime, arrayPositionEstimatedDoa(3,:) - arrayPositionTrue(3,:) );
    %plot( slowTime, arrayPositionEstimatedBoth(3,:) - arrayPositionTrue(3,:) );
    xlabel( 'Slow time [s]' );
    ylabel( 'Error [m]' );
    title( 'DOA Z error' );
    %legend( 'DOA', 'DOA+FDOA' );
    hold off
    
    suptitle( 'Geolocation errors using DOA' )
end

% Plot DOA and DOA+FDOA results
if isGraphicsEnabled
    figure, subplot( 2, 1, 1 ), hold on
    Plot3dData( arrayPositionTrue, ...
        'g-', ...
        'MarkerFaceColor', 'g' );
    Plot3dData( arrayPositionEstimatedDoa, ...
        'b-.', ...
        'LineWidth', 3, ...
        'MarkerFaceColor', 'b' );
    % Plot3dData( arrayPositionEstimatedFdoa, ...
    %     'bd-.', ...
    %     'LineWidth', 3, ...
    %     'MarkerFaceColor', 'b' );
    Plot3dData( arrayPositionEstimatedBoth, ...
        'r-.', ...
        'LineWidth', 3, ...
        'MarkerFaceColor', 'r' );
    Plot3dData( [sourceAssumed.position], 'rp', ...
        'MarkerFaceColor', 'r', ...
        'MarkerSize', 15 );
    legend( 'True', 'DOA', 'DOA+FDOA' )
    view( [-13 30] )
    xlabel( 'Easting [m]' ), ylabel( 'Northing [m]' ), zlabel( 'Altitude [m]' )
    title( 'Platform trajectory' )
    hold off
    
    subplot( 2, 1, 2 )
    [hAx,hLine1,hLine2] = plotyy( [slowTime', slowTime'], [ColumnNorm( arrayPositionEstimationErrorDoa )', ColumnNorm( arrayPositionEstimationErrorBoth )'], ...
        slowTime, ColumnNorm( arrayPositionEstimationErrorBoth ) ./ ColumnNorm( arrayPositionEstimationErrorDoa ) );
    legend( 'DOA', 'DOA+FDOA' )
    ylabel(hAx(1),'Error norm [m]') % left y-axis
    ylabel(hAx(2),'DOA+FDOA/DOA error ratio') % right y-axis
    title( 'Platform position estimation error' )
    xlabel( 'Slow time [s]' )
    
    figure
    
    subplot( 1, 3, 1 ), hold on
    plot( slowTime, arrayPositionEstimatedDoa(1,:) - arrayPositionTrue(1,:) );
    plot( slowTime, arrayPositionEstimatedBoth(1,:) - arrayPositionTrue(1,:) );
    xlabel( 'Slow time [s]' );
    ylabel( 'Error [m]' );
    title( 'X error' );
    legend( 'DOA', 'DOA+FDOA' );
    hold off
    
    subplot( 1, 3, 2 ), hold on
    plot( slowTime, arrayPositionEstimatedDoa(2,:) - arrayPositionTrue(2,:) );
    plot( slowTime, arrayPositionEstimatedBoth(2,:) - arrayPositionTrue(2,:) );
    xlabel( 'Slow time [s]' );
    ylabel( 'Error [m]' );
    title( 'Y error' );
    legend( 'DOA', 'DOA+FDOA' );
    hold off
    
    subplot( 1, 3, 3 ), hold on
    plot( slowTime, arrayPositionEstimatedDoa(3,:) - arrayPositionTrue(3,:) );
    plot( slowTime, arrayPositionEstimatedBoth(3,:) - arrayPositionTrue(3,:) );
    xlabel( 'Slow time [s]' );
    ylabel( 'Error [m]' );
    title( 'Z error' );
    legend( 'DOA', 'DOA+FDOA' );
    hold off
    
    suptitle( 'Geolocation errors using DOA or DOA+FDOA' )
end

%%

saveFolder = [ './mat', num2str( noiseSnr ) ]; % ./mat20 for snr=20, etc.
save( tempname( saveFolder ), ...
    'arrayPositionEstimatedDoa', 'arrayPositionEstimatedBoth', 'arrayPositionTrue', ...
    'sourcePositionEstimated', 'sourcePosition', 'noiseSnr', 'clockShiftAverage' );