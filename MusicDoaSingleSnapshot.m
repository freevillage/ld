function directions = MusicDoaSingleSnapshot( arrayData, totalMonochromeComponents )

[~,~,V] = svd( toeplitz( arrayData(totalMonochromeComponents+1:end), arrayData(totalMonochromeComponents+1:-1:1) ) );
directions = sort( mod( -angle( conj( roots( V(:,end) ) ) ), 2*pi ) / pi );

end % of function