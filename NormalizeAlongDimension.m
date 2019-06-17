function datasetNormalized = NormalizeAlongDimension( dataset, dimension, normIndex )

assert( ndims( dataset ) <= 2 );
if nargin < 3
    normIndex = 2;
end

if ndims( dataset ) == 1
    datasetNormalized = Normalize( dataset, normIndex );
else % ndims (dataset) == 2
    datasetNormalized = dataset;
    assert( dimension == 1 || dimension == 2 )
    if dimension == 1
        
        totalTraces = size( dataset, 2 );
        for iTrace = 1 : totalTraces
            dataset(:,iTrace) = Normalize( dataset(:,iTrace), normIndex );
        end
    else
        
        totalTraces = size( dataset, 1 );
        for iTrace = 1 : totalTraces
            datasetNormalized(iTrace,:) = Normalize( dataset(iTrace,:), normIndex );
        end
        
    end
end

end