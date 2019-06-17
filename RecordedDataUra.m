function recordedData = RecordedDataUra( receiverPosition, source, time )

% Quick hack to add freq perturbations
% totalSourceComponents = length( source.amplitude );
% freqStd = 1e-50; % Hz
% freqStds = freqStd * ones( totalSourceComponents, 1 );
% end of hack

sizeReceiverPosition = size( receiverPosition );
assert( ismatrix( time ) );
time = permute( repmat( time, [ 1, 1, sizeReceiverPosition(2:3) ] ), [3 4 1 2] );
sourcePosition = repmat( ToColumn( source.position ), [ 1 sizeReceiverPosition(2:end) ] );
distance = squeeze( sqrt( sum( (receiverPosition - sourcePosition) .^ 2 ) ) );

% sizeTime = size( time );
% totalSlowTimes = sizeTime(4);
% freqStdsSlow = repmat( reshape( (ToColumn( freqStds ) * ones( 1, totalSlowTimes )) , [totalSourceComponents 1 1 1 totalSlowTimes] ), [1 sizeTime(1:end-1) 1] );

recordedData = RecordedDataTime( ...
    ToColumn( time ), ToColumn( distance ), ...
    source.amplitude, source.frequency, source.phase ...
    );

recordedData = reshape( recordedData, sizeReceiverPosition(2:end) );


end