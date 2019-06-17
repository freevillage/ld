function IsSourceReceiverFlipped = WriteModelToFile( Model, SourceNumber, ReceiverNumber, Filename )

% This function creates an input file to be used by the Discrete Wavenumber
% Propagator. The latter allows a single shot and a single receiver only.
% When the model contains many sources and receivers, traces must be
% computed for each shot-receiver pair in a loop.

% The propagator as written now uses a default name for the input file. If
% another version of the same code is used, an arbitrary filename can be
% passed as an optional argument.
DefaultFilename = 'Input_model.asc';
if( nargin < 4 )
    Filename = DefaultFilename;
end

% Obtain source and receiver locations. The code demans that the source
% always lie deeper than the receiver. If this is not the case we use the
% elastic reciprocity and flip them around. Because both sources are
% explosive, this should be alright. 
SourceLocation = Model.SourceLocation( :, SourceNumber );
ReceiverLocation = Model.ReceiverLocation( :, ReceiverNumber );

if( SourceLocation( 3 ) <= ReceiverLocation( 3 ) )
    Temp = SourceLocation;
    SourceLocation = ReceiverLocation;
    ReceiverLocation = Temp;
    
    IsSourceReceiverFlipped = true;
else
    IsSourceReceiverFlipped = false;
end

% Open the file to be filled with model parameters for writing. If there is
% a problem, exit with an error.
ModelFileID = fopen( Filename, 'w' );
if( ModelFileID == -1 )
    error( 'WriteModelToFile:CannotOpenFile', ...
           'Cannot create input file' );
end

TotalLayers = length( Model.Layers.Thickness );

% First line is the total number of layers in the medium
fprintf( ModelFileID, '%d\n', TotalLayers );

% Then go lines describing each layer. The thickness of the last layer must
% be zero.
Model.Layers.Thickness( TotalLayers ) = 0;

for IndexLayer = 1 : TotalLayers
    fprintf( ModelFileID, '%f %f %f %f %f %f\n', ...
        Model.Layers.Thickness(IndexLayer) / 1000, ...
        Model.Layers.Vp(IndexLayer) / 1000, ...
        Model.Layers.Vs(IndexLayer) / 1000, ...
        Model.Layers.Density(IndexLayer), ...
        Model.Layers.Qp(IndexLayer), ...
        Model.Layers.Qs(IndexLayer) );
end

% Then goes the depth of the source
fprintf( ModelFileID, '%f\n', double( SourceLocation( 3 ) ) / 1000 );

% Then strike, dip, rake, slip, which are default values because the source  
% is always explosive in this model.
ExplosiveStrike = 90;
ExplosiveDip = 90;
ExplosiveRake = 90; 
ExplosiveSlip = 1;
fprintf( ModelFileID, '%f %f %f\n%f\n', ...
    ExplosiveStrike, ...
    ExplosiveDip, ...
    ExplosiveRake, ...
    ExplosiveSlip );

% Then fault length
fprintf( ModelFileID, '%f\n', Model.SourceAmplitude( SourceNumber ) );

% Number of receiver and their depth. In this implementaiton the number of
% receivers must be always 1.
TotalReceivers = 1;
fprintf( ModelFileID, '%d %f\n', ...
    TotalReceivers, ...
    double( ReceiverLocation( 3 ) ) / 1000 );

% Source-receiver offset and receiver azimuth evaluated clockwise relative 
% to the north.
% The coordinate system is af follows:
%  x - North
%  y - East
%  z - Down
SourceReceiverOffset = norm( [ ReceiverLocation( 1 ) - SourceLocation( 1 ), ...
    - ReceiverLocation( 2 ) + SourceLocation( 2 ) ] );
SourceReceiverAzimuth = rad2deg( atan2( ...
    - ReceiverLocation( 2 ) + SourceLocation( 2 ), ...
    ReceiverLocation( 1 ) - SourceLocation( 1 ) ) );
fprintf( ModelFileID, '%f %f\n', ...
    SourceReceiverOffset / 1000, ...
    SourceReceiverAzimuth );

% Totalnumber of time samples and the recording length. The number of time
% samples must be a power of 2.
TotalTimes = length( Model.RecordingTimes );
if( ~IsPowerOfTwo( TotalTimes ) )
    error( 'WriteModelToFile:TimesNotPowerTwo', ...
           'The number of time samples must be a power of 2!' );
end

RecordingLength = Model.RecordingTimes( end ) - Model.RecordingTimes( 1 );

fprintf( ModelFileID, '%d %f\n', ...
    TotalTimes, ...
    RecordingLength );

% Souce initial time and initial recordingtime
fprintf( ModelFileID, '%f %f\n', ...
    1 / Model.SourceFrequency( SourceNumber ), ...
    Model.RecordingTimes( 1 ) );

% Wavenumber max and periodicity length are two internal parameters that
% are kept at default values.
WavenumberMax = 10000;
PeriodicityLength = 10;
fprintf( ModelFileID, '%d %d\n', ...
    WavenumberMax, ...
    PeriodicityLength );

% All parameters have been written into the file. We can close it and
% return from the function
fclose( ModelFileID );

end % of WriteModelToFile