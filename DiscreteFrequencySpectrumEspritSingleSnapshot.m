function phases = DiscreteFrequencySpectrumEspritSingleSnapshot( arrayData, totalPhases )

assert( isvector( arrayData ) && isnumeric( arrayData ) );

arrayData = ToColumn( arrayData );

totalAntennas = length( arrayData );
[U,~,~] = svd( hankel( arrayData(1 : totalAntennas-totalPhases), arrayData(totalAntennas-totalPhases : totalAntennas-1) ) );
%phases = sort( mod( -angle( conj( eig( pinv( U(1:end-1,1:totalPhases) ) * U(2:end,1:totalPhases) ) ) ), 2*pi ) / pi );
phases = sort( mod( -angle( conj( eig(  U(1:end-1,1:totalPhases) \ U(2:end,1:totalPhases) ) ) ), 2*pi ) / pi );

phases = WrapToOne( phases );


end % of function