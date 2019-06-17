function phases = EspritInversionSingleSnapshot( arrayData, totalMonochromeComponents )

assert( isvector( arrayData ) && isnumeric( arrayData ) );

arrayData = ToColumn( arrayData );

totalAntennas = length( arrayData );
[U,~,~] = svd( hankel( arrayData(1 : totalAntennas-totalMonochromeComponents), arrayData(totalAntennas-totalMonochromeComponents : totalAntennas-1) ) );
phases = sort( mod( -angle( conj( eig( pinv( U(1:end-1,1:totalMonochromeComponents) ) * U(2:end,1:totalMonochromeComponents) ) ) ), 2*pi ) / pi );

phases = WrapToOne( phases );


end % of function