function varargout = FindLargestPeaks( data, totalPeaks )

[peaks, peakLocations] = findpeaks( data );
[sortedPeaks, sortedOrder] = sort( peaks, 'descend' );
sortedPeakLocations = peakLocations(sortedOrder);

largestPeakLocations = sortedPeakLocations(1:totalPeaks);
largestPeaks = sortedPeaks(1:totalPeaks);

varargout{1} = largestPeakLocations;
    
if nargout == 2
    varargout{2} = largestPeaks;
end

end