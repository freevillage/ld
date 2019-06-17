function smoothedData = smoothMulticomponent( data, subset, span, method )

totalPoints = length( data );

if( nargin < 4 )
    method = 'moving';
    if( nargin < 3 )
        span = 5;
        if( nargin < 2 )
            subset = 1 : totalPoints;
        end
    end
end

smoothedData = data;

[ totalComponents, begComponent, endComponent ] = findConnectedComponents( subset, totalPoints );

for iComponent = 1 : totalComponents
    insideComponent = begComponent( iComponent ) : endComponent( iComponent );
    smoothedData( insideComponent ) = smooth( data( insideComponent ), span, method );
end

end