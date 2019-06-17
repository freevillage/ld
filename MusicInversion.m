function phases = MusicInversion( arrayData, totalMonochromeComponents )

if isvector( arrayData )
    arrayData = ToColumn( arrayData );
end

totalSnapshots = size( arrayData, 2 );
phases = nan( totalMonochromeComponents, totalSnapshots );

for iSnapshot = 1 : totalSnapshots
    phases(:,iSnapshot) = MusicInversionSingleSnapshot( arrayData(:,iSnapshot), totalMonochromeComponents );
end

phases = mean( phases, 2 ); % average over snapshots

end % of function