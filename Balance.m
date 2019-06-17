function datasetBalanced = Balance( dataset, dimension )

if nargin == 1
    dimension = 1;
end

datasetBalanced = dataset;
valuesOriginal = dataset.Values;
meanValues = mean( valuesOriginal, dimension );
repeatAlongDimension = ones( 1, ndims( dataset ) );
repeatAlongDimension( dimension ) = size( dataset, dimension );
meanMatrix = repmat( meanValues, repeatAlongDimension );
balancedValues = valuesOriginal - meanMatrix;
datasetBalanced.Values = balancedValues;

end