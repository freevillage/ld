function dataset = AndreyToDataset( dataFilename )

assert( ischar( dataFilename ), 'Invalid filename: must be a string!' );
assert( exist( dataFilename, 'file' ), 'Could not find data file!' );

headerFilename = sprintf( '.%s.header', dataFilename );
assert( exist( headerFilename, 'file'  ), 'Could not find header file!' );

% Read the data stream
datasetValues = readBinaryFile( dataFilename );

% Read and parse the header
headerFileID = FileOpen( headerFilename );
headerContents = textscan( headerFileID, '%s %s %s' );
FileClose( headerFilename );

fieldNames  = headerContents{1};
fieldValues = headerContents{3};

axisTotalPoints = cellfun( @(string) str2double( cell2mat( fieldValues( strcmp( string, fieldNames ) ) ) ), ...
    { 'index1', 'index2', 'index3', 'index4' } );

axisSteps = cellfun( @(string) str2double( cell2mat( fieldValues( strcmp( string, fieldNames ) ) ) ), ...
    { 'index1_step', 'index2_step', 'index3_step', 'index4_step' } );

axisTypes = cellfun( @(string) str2double( cell2mat( fieldValues( strcmp( string, fieldNames ) ) ) ), ...
    { 'index1_type', 'index2_type', 'index3_type', 'index4_type' } );

datasetName = fieldValues( strcmp( 'type', fieldNames ) );
datasetUnits = fieldValues( strcmp( 'units', fieldNames ) );

totalDimensions = find( axisTotalPoints > 1, 1, 'last' );
datasetAxes = cell( totalDimensions, 1 );

for iDimension = 1 : totalDimensions
    datasetAxes = GraphAxis( RsfLinspace( 0, axisSteps(iDimension), axisTotalPoints ), axisTypes, '' );
end

dataset = DatasetNd( datasetAxes{:}, datasetValues, datasetName, datasetUnits );

end