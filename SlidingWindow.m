function result = SlidingWindow( fcn, signal, windowLength, name, units, varargin )

assert( false );

assert( IsDataset( signal ) ...
    && isvector( signal ) );

windowLengthInPts = floor( windowLength / signal.Axes.Step );
slidingWindowSize = [ windowLengthInPts 1 ];

signalValues = signal.Values;

resultValues = nlfilter( signalValues, slidingWindowSize, ...
    @(values) double( feval( fcn, DatasetNd( signal.Axes, signal.Values, varargin{:} ) ) ) );





end