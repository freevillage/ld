function clusters = ClusterEarthquakes( earthquakes )

% totalEarthquakes = length( earthquakes );
% longitude = nan( totalEarthquakes, 1 );
% latitude  = nan( totalEarthquakes, 1 );
% depth     = nan( totalEarthquakes, 1 );
%
% SetProgressBarType Graphics;
% waitBar = ProgressBar( 'Name', 'Loading earthquake data' );
%
% for iEarthquake = 1 : totalEarthquakes
%     thisEarthquake = LoadEarthquakeData( EarthquakeFileName('./Data',earthquakes(iEarthquake).name) );
%     longitude(iEarthquake) = thisEarthquake.evlon;
%     latitude(iEarthquake)  = thisEarthquake.evlat;
%     depth(iEarthquake) = thisEarthquake.evdep;
%     if rem( totalEarthquakes, iEarthquake ) == 100
%         waitBar.SetProgress( iEarthquake/totalEarthquakes );
%     end
% end
%
% waitBar.Delete;
% disp( 'Earthquake data loaded' );
%save( 'points_for_clustering.mat', 'longitude', 'latitude', 'depth' );
load( 'points_for_clustering.mat' );

clusters = ClusterPoints( [ longitude, latitude, 1000*depth ] );

disp( 'Clusters computed' );

totalClusters = sum( any( ~isnan(clusters), 2) );
colorMap = hsv( totalClusters );

figure( 'Name', 'Clusters of earthquakes' );
hold on;

for iCluster = 1 : totalClusters
    earthquakesInCluster = clusters(iCluster, ~isnan( clusters(iCluster,:) ) );
    totalEarthquakesInCluster = length( earthquakesInCluster );
    if totalEarthquakesInCluster > 2
        plot3( longitude(earthquakesInCluster), latitude(earthquakesInCluster), depth(earthquakesInCluster), ...
            '*', ...
            'Color', colorMap(iCluster,:) );
        text( longitude(earthquakesInCluster(1)), latitude(earthquakesInCluster(1)), depth(earthquakesInCluster(1)), ...
            num2str( iCluster ) );
    end
end


stationInfos = MedusaStationInfo;
plot3( [stationInfos.lon], [stationInfos.lat], -[stationInfos.elev], ...
    'g^' );



hold off;

set( gca, 'ZDir', 'Reverse' );
xlabel( 'Longitude' );
ylabel( 'Latitude' );
zlabel( 'Depth' );

end