function [ Times, Traces ] = ReadTracesFromFile( Filename )

% The discrete wavenumber code as written now uses a default filename for
% its output. If another version of the same code is used, the filename can
% be passed as an optional argument. 
DefaultFilename = 'Output_traces.asc';
if( nargin < 1 )
    Filename = DefaultFilename;
end

FileData = load( Filename );

% It is assumed in what follows that a single 3C receiver has recorded a
% signal caused by a single shot. 
TotalComponents = 3;

% The first column should contain component numbers. First goes the signal
% from the first component, then from the second, and finally form the
% third. We know this a priori and can therefore ignore the first column.

% The second column contains time samples repeated three times. We only
% need to read one copy. 
TotalTimes = size( FileData, 1 ) / TotalComponents;
Times = FileData( 1 : TotalTimes, 2 );

% The third column contains the signal from each component. It is reshaped
% to a more natural form.
RecordedSignal = FileData( :, 3 );
Traces = reshape( RecordedSignal, [ TotalTimes TotalComponents ] );

end % of ReadTracesFromFile