function directions = EspritInversion( arrayData, totalMonochromeComponents )

totalSnapshots = size( arrayData, 2 );
directions = nan( totalMonochromeComponents, totalSnapshots );

for iSnapshot = 1 : totalSnapshots
    directions(:,iSnapshot) = EspritInversionSingleSnapshot( arrayData(:,iSnapshot), totalMonochromeComponents );
end

directions = mean( directions, 2 ); % average over snapshots

end % of function