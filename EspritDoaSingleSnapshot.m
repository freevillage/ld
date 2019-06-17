function directions = EspritDoaSingleSnapshot( arrayData, totalMonochromeComponents )

assert( isvector( arrayData ) && isnumeric( arrayData ) );

arrayData = ToColumn( arrayData );

totalAntennas = length( arrayData );
[U,~,~] = svd( hankel( arrayData(1 : totalAntennas-totalMonochromeComponents), arrayData(totalAntennas-totalMonochromeComponents : totalAntennas-1) ) );
directions = sort( mod( -angle( conj( eig( pinv( U(1:end-1,1:totalMonochromeComponents) ) * U(2:end,1:totalMonochromeComponents) ) ) ), 2*pi ) / pi );

end % of function