function dataset = NanDataset( varargin )

totalInputs = nargin;
sizeDataset = nan( 1, totalInputs );

for iInput = 1:totalInputs
    thisAxis = varargin{iInput};
    assert( IsGraphAxis( thisAxis ) );
    sizeDataset(iInput) = thisAxis.TotalPoints;
end

if length( sizeDataset ) == 1
    sizeDataset = [1 sizeDataset];
end

dataset = DatasetNd( varargin{:}, nan( sizeDataset ) );

end