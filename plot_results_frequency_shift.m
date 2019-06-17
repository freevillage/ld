loadFolder = './mat41';
files = dir( loadFolder );
totalFiles = length( files );
filename = cell( totalFiles, 1 );
for iFile = 1 : totalFiles
    filename{iFile} = files(iFile).name;
end
filename = filename(3:end);
totalFiles = length( filename );

res = cell( totalFiles, 1 );

for iFile = 1 : totalFiles
    res{iFile} = load( fullfile( loadFolder, filename{iFile} ) );
end

res = res( cellfun( @(r) isfield( r, 'clockShiftAverage' ), res ) );
res = [res{:}];

clockShifts = [res.clockShiftAverage];
errorSourcePosition = transpose( squeeze( sqrt( sum ( (cat(3,res.sourcePosition) - cat(3,res.sourcePositionEstimated)) .^ 2 ) ) ) );

[sortedClockShifts, indexSort] = sort( clockShifts );

figure
plot( sortedClockShifts, errorSourcePosition(indexSort,:), 'LineWidth', 1 )
xlabel( 'Frequency shift [Hz]' )
ylabel( 'Source location error [m]' )
title( 'Source location error' )
legend( '1', '2', '3', 'Location', 'NorthWest'  )

slowTime = 0 : 20;

errorArrayPositionDoa = transpose( squeeze( sqrt( sum( ( cat( 3, res.arrayPositionTrue ) - cat( 3, res.arrayPositionEstimatedDoa ) ) .^ 2 ) ) ) );
errorArrayPositionBoth = transpose( squeeze( sqrt( sum( ( cat( 3, res.arrayPositionTrue ) - cat( 3, res.arrayPositionEstimatedBoth ) ) .^ 2 ) ) ) );


figure
subplot( 2, 1, 1 )
surf( sortedClockShifts, slowTime, errorArrayPositionDoa(indexSort,:)' )

subplot( 2, 1, 2 )
qq = errorArrayPositionBoth(indexSort,:)';
surf( sortedClockShifts, slowTime(2:end-1), qq(2:end-1,:) )
