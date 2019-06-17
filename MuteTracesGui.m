function gatherMuted = MuteTracesGui( gather, whereToMute, muteValue )

if nargin < 3
    muteValue = 0.0;
end

figure( 'Name', 'Initial gather' );
display( gather );

[xPressed, yPressed] = ginput;
if isempty( xPressed )
    gatherMuted = gather;
    
else
    [xPressed, sortingIndex] = sort( xPressed );
    yPressed = yPressed(sortingIndex);
    
    axTraces = gather.Axes(1);
    timesSelected = interp1( xPressed, yPressed, axTraces.Locations, 'linear', 'extrap' );
    times = gather.Axes(2).Locations;
    
    newValues = gather.Values;
    
    for iTrace = 1 : axTraces.TotalPoints
        thisTimeSelected = timesSelected(iTrace);
        indexTime = find( times >= thisTimeSelected, 1 );
        if strcmp( whereToMute, 'before' )
            newValues(iTrace,1:indexTime) = muteValue;
        elseif strcmp( whereToMute, 'after' )
            newValues(iTrace,indexTime:end) = muteValue;
        end
    end
    
    gatherMuted = DatasetNd( gather.Axes(1), gather.Axes(2), newValues );    
end
cla;
display( gatherMuted );
set( gcf, 'Name', 'Muted gather' );

end