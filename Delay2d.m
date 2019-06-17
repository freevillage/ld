function datasetDelayed = Delay2d( dataset, delays )

totalTraces = size( dataset, 1 );
datasetDelayed = dataset;

for iTrace = 1 : totalTraces
    datasetDelayed(iTrace,:) = Delay1d( dataset(iTrace,:), delays(iTrace) );
end

end