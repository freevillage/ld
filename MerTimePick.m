function pickedTimes = MerTimePick( gather, windowLength, maximumEvents )

totalDimensions = ndims( gather );
assert( totalDimensions <= 2 );

if nargin < 3
    maximumEvents = 1;
end

if totalDimensions == 1
    pickedTimes = MerTimePick1d( gather, windowLength, maximumEvents );
elseif totalDimensions == 2
    pickedTimes = MerTimePick2d( gather, windowLength, maximumEvents );
else
    error( 'Wrong dimensions' );
end


end


function eventTime = MerTimePickFirstEvent( trace, windowSize, merThreshold, waterLevel )

if nargin < 4
    waterLevel = .01;
end
if nargin < 3
    merThreshold = 0.01;
end

assert( ndims( trace ) == 1 );
trace = Normalize( trace );

merSamples = ModifiedEnergyRatio( trace.Values, floor( windowSize/(2*trace.Axes.Step) ), waterLevel );
eventTimeIndex = find( merSamples >= merThreshold, 1, 'first' );
eventTime = trace.Axes.Points(eventTimeIndex);

end

function pickedTimes = MerTimePick1d( trace, windowSize, maximumEvents )

assert( ndims( trace ) == 1 );

eventAxis = GraphAxis( 1:maximumEvents, 'Event', '' );
pickedTimes = NanDataset( eventAxis );

totalEventsDetected = 0;
searchWindow = [ trace.Axes.Min ; trace.Axes.Max ];

while totalEventsDetected < maximumEvents
   eventTime = MerTimePickFirstEvent( trace(searchWindow), windowSize );
   if ~isnan( eventTime )
       totalEventsDetected = totalEventsDetected + 1;
       pickedTimes(totalEventsDetected) = eventTime;
       searchWindow = [ eventTime+windowSize ; trace.Axes.Max ];
   else
       return
   end
end

end


function eventTimes = MerTimePick2d( gather, windowSize, maximumEvents )

assert( ismatrix( gather ) );

traceAxis = gather.Axes(1);

if maximumEvents > 1
    eventAxis = GraphAxis( 1:maximumEvents, 'Event', '' );
    eventTimes = NanDataset( traceAxis, eventAxis );
elseif maximumEvents == 1
    eventTimes = NanDataset( traceAxis );
else
    error( 'maximuEvents must be a positive integer' );
end

totalTraces = traceAxis.TotalPoints;

for iTrace = 1 : totalTraces
    if maximumEvents > 1
        eventTimes(iTrace,:) = MerTimePick1d( gather(iTrace,:), windowSize, maximumEvents );
    else
        eventTimes(iTrace) = MerTimePick1d( gather(iTrace,:), windowSize, maximumEvents );
    end
end


end