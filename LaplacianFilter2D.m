function dataFiltered = LaplacianFilter2D( data, alpha, varargin )

if nargin < 2
    alpha = 0.2;
end

filterLaplacian = fspecial( 'laplacian', alpha );

dataFiltered = data;
dataFiltered(:,:) = imfilter( data.Values, filterLaplacian, varargin{:} );

end