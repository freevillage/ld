
function [ AxisFrequency, SignalFrequency ] = CenteredFourierTransform( AxisTime, SignalTime, varargin )

% If SignalTime contains more than one signals, a dimension over which FT
% is to cos t be computed needs to be specified
if( nargin == 2 )
    Dimension     = 2;
else 
    Dimension     = varargin{ 1 };
end

TotalTimes        = size( SignalTime, Dimension );
SamplingFrequency = 2 * pi / AxisTime.Step;

if( IsEven( TotalTimes ) )
    IntegerTimes  = -TotalTimes/2 : TotalTimes/2 - 1;
else
    IntegerTimes  = -(TotalTimes-1)/2 : (TotalTimes-1)/2;
end

Frequencies       = IntegerTimes / TotalTimes * SamplingFrequency;
AxisFrequency     = GraphAxis( Frequencies, 'Frequency', 'Hz' );

SignalFrequency   = fftshift( fft( SignalTime, [], Dimension ), ...
                            Dimension ) ...
                  / TotalTimes;

end