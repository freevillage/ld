function freqs = DiscreteFrequencySpectrumHertzUra( arrayData, freqSampling, varargin )

assert( ndims( arrayData ) == 3 );
[totalAntennasX, totalAntennasY, totalSnapshots] = size( arrayData );
totalAntennas = totalAntennasX * totalAntennasY;

% Slower but slightly more readable version follows here:

% Make time the fast dimension for speed of execution
%arrayData = permute( arrayData, [3 1 2] );
%freqs = cell( totalAntennasX, totalAntennasY );
% parfor ix = 1 : totalAntennasX
%     for jy = 1 : totalAntennasY
%         antennaData = arrayData(:,ix,jy);
%         freqs{ix,jy} = ToColumn( DiscreteFrequencySpectrumHertz( antennaData, freqSampling, varargin{:} ) );
%     end
% end
%totalFreqs = length( freqs{1,1} );
%freqs = shiftdim( reshape( cell2mat( freqs ), [totalFreqs, totalAntennasX, totalAntennasY] ), 1 );

% Faster version (due to better parallelism) follows here:

reshapedArrayData = transpose( reshape( arrayData, totalAntennas, totalSnapshots ) );
iAntenna = 1;

% Process the first antenna to figure out the size of the output and
% allocate the proper chunck of memory
freqsFirst = DiscreteFrequencySpectrumHertz( reshapedArrayData(:,iAntenna), freqSampling, varargin{:} );
totalFreqs = length( freqsFirst );
freqs = nan( totalFreqs, totalAntennas );
freqs(:,iAntenna) = freqsFirst;

% Now process all antennas except the first in parallel
parfor iAntenna = 2 : totalAntennas
    antennaData = reshapedArrayData(:,iAntenna);
    freqs(:,iAntenna) = DiscreteFrequencySpectrumHertz( antennaData, freqSampling, varargin{:} ); %#ok<PFBNS>
end

freqs = reshape( freqs, totalFreqs, totalAntennasX, totalAntennasY );

end % of function 