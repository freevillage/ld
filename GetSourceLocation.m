function output = GetSourceLocation( varargin )

%% Parse input
input = inputParser;

defaultClockShift = 0; % Hz
defaultAspectAngle = pi/2; % rad
defaultSigmaNoise = 1e-9; 
defaultSourceFrequency = 300e6; % Hz
defaultSourcePhase = 0;
defaultSourcePositionFcn = @(t) [0; 0; 0]; % m
defaultSourceAmplitude = 1;
defaultSlowTimeStart = 0;
defaultSlowTimeEnd = 1;
defaultSlowTimeSamplingFrequency = 1; % Hz
defaultFastTimeStart = 0;
defaultFastTimeEnd = 1e-6; % sec
defaultFastTimeSamplingFrequency = 1e9; % Hz
defaultArrayPositionFcn = @(t) [ -400; 0; 3000 ]; % historic initial position of no physical significance
defaultRotationFcn = @(t) eye(3);
c = physconst('LightSpeed');
defaultWavelength = c/defaultSourceFrequency;
defaultTotalElements = [ 11 11 ];
defaultElementSpacing = defaultWavelength * [0.5 0.5];
defaultMethodDescription = { 'Method', 'Prony' };
defaultActiveArrayWindow = [];

addParameter( input, 'SourceClockShift', defaultClockShift, @isscalar );
addParameter( input, 'AspectAngle', defaultAspectAngle, @isscalar );
addParameter( input, 'SigmaNoise', defaultSigmaNoise, @IsPositiveScalar );
addParameter( input, 'SourceFrequency', defaultSourceFrequency, @IsPositiveScalar );
addParameter( input, 'SourcePhase', defaultSourcePhase, @isscalar );
addParameter( input, 'SourceAmplitude', defaultSourceAmplitude, @IsPositiveScalar );
addParameter( input, 'SourcePositionFcn', defaultSourcePositionFcn, @(fh) isa(fh, 'function_handle') || iscell(fh) );
addParameter( input, 'SlowTimeStart', defaultSlowTimeStart, @isscalar );
addParameter( input, 'SlowTimeEnd', defaultSlowTimeEnd, @isscalar );
addParameter( input, 'SlowTimeSamplingFrequency', defaultSlowTimeSamplingFrequency, @IsPositiveScalar );
addParameter( input, 'FastTimeStart', defaultFastTimeStart, @isscalar );
addParameter( input, 'FastTimeEnd', defaultFastTimeEnd, @isscalar );
addParameter( input, 'FastTimeSamplingFrequency', defaultFastTimeSamplingFrequency, @IsPositiveScalar );
addParameter( input, 'ArrayPositionFcn', defaultArrayPositionFcn, @(fh) isa(fh, 'function_handle') );
addParameter( input, 'RotationFcn', defaultRotationFcn, @(fh) isa(fh, 'function_handle')  );
addParameter( input, 'TotalElements', defaultTotalElements, @isvector );
addParameter( input, 'ElementSpacing', defaultElementSpacing, @isvector );
addParameter( input, 'MethodDescription', defaultMethodDescription, @(methodDescription) ischar(methodDescription) || iscell(methodDescription)  );
addParameter( input, 'ActiveArrayWindow', defaultActiveArrayWindow );


if isempty(varargin{1})
    varargin = { 'SourceClockShift', defaultClockShift };
end
parse( input, varargin{:} );

totalAntennasX = input.Results.TotalElements(1);
totalAntennasY = input.Results.TotalElements(2);

activeArrayWindow = input.Results.ActiveArrayWindow;
if isempty( activeArrayWindow )
    activeArrayWindow = { 1 : totalAntennasX, 1 : totalAntennasY };
end

if iscell( input.Results.SourcePositionFcn ) 
    GetSourcePosition = input.Results.SourcePositionFcn;
else
    GetSourcePosition = {input.Results.SourcePositionFcn};
end

totalSources = length( GetSourcePosition );

sourceFrequency = PadSourceParameters( input.Results.SourceFrequency, totalSources );
sourcePhase = PadSourceParameters( input.Results.SourcePhase, totalSources );
sourceAmplitude = PadSourceParameters( input.Results.SourceAmplitude, totalSources );
sourceClockShift = PadSourceParameters( input.Results.SourceClockShift, totalSources );

%% Generate array path

slowTime = input.Results.SlowTimeStart : 1/input.Results.SlowTimeSamplingFrequency : input.Results.SlowTimeEnd;
totalSlowTimes = length( slowTime );

fastDelay = input.Results.FastTimeStart : 1/input.Results.FastTimeSamplingFrequency : input.Results.FastTimeEnd;
totalFastTimes = length( fastDelay );

fastTime = bsxfun( @plus, ToColumn(slowTime), ToRow(fastDelay) );

arrayPosition = nan( 3, totalSlowTimes, totalFastTimes );
receiverPosition = nan( totalSlowTimes, totalFastTimes, 3, totalAntennasX, totalAntennasY );
GetArrayPosition = input.Results.ArrayPositionFcn;
GetRotation = input.Results.RotationFcn;

for iSlow = 1 : totalSlowTimes
    for jFast = 1 : totalFastTimes
        thisFastTime = fastTime(iSlow,jFast);
        thisArrayPosition = GetArrayPosition( thisFastTime );
        thisRotation = GetRotation( thisFastTime );
        
        arrayPosition(:,iSlow,jFast) = thisArrayPosition;
        
        receiverPosition(iSlow,jFast,:,:,:) = UniformRectangularArray( ...
            (input.Results.TotalElements-1) .* input.Results.ElementSpacing, ...
            input.Results.TotalElements, ...
            thisArrayPosition, ...
            thisRotation );
    end
end


%% True angles

anglesTrue = nan( 2, totalSources, totalSlowTimes, totalFastTimes );

for iSource = 1 : totalSources
    thisGetSourcePosition = GetSourcePosition{iSource};
    for iSlow = 1 : totalSlowTimes
        for jFast = 1 : totalFastTimes
            thisArrayPosition = ToColumn( arrayPosition(:,iSlow,jFast) );
            thisFastTime = fastTime(iSlow,jFast);
            thisRotationMatrix = GetRotation( thisFastTime );
            thisSourcePosition = ToColumn( thisGetSourcePosition( thisFastTime ) );
            
            xRotated = thisRotationMatrix * [1;0;0];
            yRotated = thisRotationMatrix * [0;1;0];
            
            anglesTrue(1,iSource,iSlow,jFast) = pi/2 - AngleBetweenVectors3D(thisSourcePosition - thisArrayPosition, xRotated );
            anglesTrue(2,iSource,iSlow,jFast) = pi/2 - AngleBetweenVectors3D(thisSourcePosition - thisArrayPosition, yRotated );
        end
    end
end

%% Simulating recorded data

recordedData = nan( totalSources, totalSlowTimes, totalFastTimes, totalAntennasX, totalAntennasY );
cleanData    = nan( totalSources, totalSlowTimes, totalFastTimes, totalAntennasX, totalAntennasY );
dataSNR = nan( totalSources, totalSlowTimes );

for iSource = 1 : totalSources
    thisGetSourcePosition = GetSourcePosition{iSource};
    for kSlow = 1 : totalSlowTimes
        for lFast = 1 : totalFastTimes
            thisFastTime = fastTime(kSlow,lFast);
            thisSourcePosition = ToColumn( thisGetSourcePosition( thisFastTime ) );
            for ix = 1 : totalAntennasX
                for jy = 1 : totalAntennasY
                    thisReceiverPosition = ToColumn( squeeze( receiverPosition( kSlow, lFast, :, ix, jy ) ) );
                    sourceReceiverDistance = norm( thisSourcePosition - thisReceiverPosition );
                    cleanData(iSource,kSlow,lFast,ix,jy) = RecordedDataTime( ...
                        thisFastTime, ...
                        sourceReceiverDistance, ...
                        sourceAmplitude(iSource), ...
                        sourceFrequency(iSource) + input.Results.SourceClockShift, ...
                        sourcePhase(iSource) );
                end
            end
        end
        
        %rng(1000+kSlow);
        
        sizeNoise = [totalFastTimes, totalAntennasX, totalAntennasY];
        dataNoise = input.Results.SigmaNoise * ( randn( sizeNoise ) + 1i * randn( sizeNoise ) );
        recordedData(iSource,kSlow,:,:,:) = squeeze(cleanData(iSource,kSlow,:,:,:)) + dataNoise;
        
        dataSNR(iSource,kSlow) = snr( ToColumn( cleanData(iSource,kSlow,:,:,:) ), ToColumn( dataNoise ) );
    end
end

%cleanData = mean( cleanData );
recordedData = squeeze( sum( recordedData, 1 ) );

% FourierAcrossArray = @(data) fft( fft( data, [], 3 ), [], 4 );
% 
% recordedDataFFT = FourierAcrossArray( recordedData );

%totalFastTimesFFT = 2^nextpow2( totalFastTimes );

%ToFourier = @(data) fft( data, totalFastTimesFFT, 2 ); % 2 - fast time dimension
%recordedDataFFT = ToFourier( recordedData ); 

%% Get source location

optimOptions = optimoptions( ...
    'fmincon', ...
    'MaxFunEvals', 1000, ...
    'MaxIter', 1000, ...
    'TolFun', 1e-9, ...
    'TolCon', 1e-9, ...
    'TolX', 1e-9...
    );
lb = [ -100 ; -100  ];
ub = [ 100 ; 100  ];

TemplateMatching = @(x,y) log( abs( dot( fft(ToColumn(x)), NormalizeVector(fft(ToColumn(y))) ) ) ); % complex dot product

% TemplateMatching = @(x,y) sum( ( abs( ToColumn(x) - ToColumn(y) ) ) .^ 2 ); % complex dot product


CostFunction = @(p) -TemplateMatching( ...
    recordedData, ...
    RecordedArrayDataTime( fastTime, receiverPosition, {@(t) [p;0]}, sourceAmplitude, sourceFrequency, sourcePhase ) );

% optimizationProblem = createOptimProblem( ...
%     'fmincon', ...
%     'objective', CostFunction, ...
%     'x0', [ -10 ; 15 ], ...
%     'lb', lb, 'ub', ub, ...
%     'options', optimOptions );

sourceLocationEstimated = fminsearch( CostFunction, [-1;1], optimOptions );

%  totalStartPoints = 10;
% [sourceLocationEstimated, ~] = run( ...
%     MultiStart( 'UseParallel', true ), ...
%     optimizationProblem, ...
%     totalStartPoints );

% [sourceLocationEstimated, ~] = run( ...
%      GlobalSearch, ...
%      optimizationProblem );

% sourceLocationEstimated = fminsearch( @(p) norm( ToColumn(recordedData - RecordedArrayDataTime( fastTime, receiverPosition, {@(t) p}, sourceAmplitude, sourceFrequency, sourcePhase )) ), ...
%     [0;0;0], ...
%     optimset( 'TolX', 1e-12, 'MaxFunEvals', 1e5 ) );

output = struct( ...
    'sourceLocation', [sourceLocationEstimated;0], ...
    'dataSNR', dataSNR ...
    );

end

function sourceParameterOut = PadSourceParameters( sourceParameterIn, totalSources )
if isscalar( sourceParameterIn )
    sourceParameterOut = sourceParameterIn .* ones( totalSources, 1 );
else
    sourceParameterOut = sourceParameterIn;
end
end