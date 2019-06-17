function phases = DiscreteFrequencySpectrumPronySingleSnapshot( arrayData, totalExponents )

[~,~,V] = svd( toeplitz( arrayData(totalExponents+1:end), arrayData(totalExponents+1:-1:1) ) );
phases = sort( WrapToOne( mod( -angle( conj( roots( V(:,end) ) ) ), 2*pi ) / pi ) );

end % of function