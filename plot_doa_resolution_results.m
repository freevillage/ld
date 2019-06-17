folderWithResults = '../mat';
filenames = dir( fullfile( folderWithResults, '*.mat' ) );

totalFilenames = length( filenames );
totalMethods = 4;

angleEstimationErrorMean = nan( 2, totalFilenames, totalMethods );
angleEstimationErrorStd = nan( 2, totalFilenames, totalMethods );
angleEstimationErrorNorm = nan( 2, totalFilenames, totalMethods );

periodsRecorded = nan( totalFilenames, 1 );
methodNames = cell( totalMethods, 1 );

for jFile = 1 : totalFilenames
    
    thisFilename = filenames(jFile);
    savedResults = load( fullfile( folderWithResults, thisFilename.name ) );
    arraySpeed = savedResults.arraySpeed;
    sigmaNoise = savedResults.sigmaNoise;
    
    periodsRecorded(jFile) = savedResults.fastRecordingTimeInPeriods;
    
    for iMethod = 1 : totalMethods
        methodNames{iMethod} = savedResults.methodDescriptions{iMethod}{2};
        anglesTrue = savedResults.anglesTrue(:,:,1);
        anglesEstimated = savedResults.anglesEstimated(:,:,iMethod);
        
        angleEstimationErrorMean(:,jFile,iMethod) = mean( transpose( anglesEstimated - anglesTrue ) );
        angleEstimationErrorStd(:,jFile,iMethod)  = std(  transpose( anglesEstimated - anglesTrue ) );
        angleEstimationErrorNorm(:,jFile,iMethod) = sqrt( sum( transpose( abs( anglesEstimated - anglesTrue ) ) ) .^2 );

    end
    
    clear savedResults
    
end

%%

[periodsRecordedSorted, sortingIndices] = sort( periodsRecorded );
figureErrorPlot = figure( 'Visible', 'off' );
loglog( periodsRecordedSorted, squeeze( angleEstimationErrorNorm(1,sortingIndices,:) ), '-' )
grid on
xlabel( 'Length of recording in fast time (periods)' )
ylabel( 'Estimation error' )
title( sprintf( 'Error as function of fast recoding time (v=%d,\\sigma=%e)', arraySpeed, sigmaNoise ) )
legend( methodNames{:} )
saveFilename = sprintf( 'html/resolution_fast_time_v_%d_%.10f.fig', arraySpeed, sigmaNoise );
savefig( figureErrorPlot, saveFilename )
close( figureErrorPlot );
