function dataFiltered = GaussianFilter2D( data, sigmas, maskFactor )

if nargin < 3
    maskFactor = 10;
end

if isscalar( sigmas )
    sigmas = [ sigmas, sigmas ];
end

sigmasInPoints = sigmas ./ [ data.Axes(1).Step, data.Axes(2).Step ];
maskSize = maskFactor .* sigmasInPoints;

filterAlongFirst  = fspecial( 'gaussian', [maskSize(1) 1], sigmasInPoints(1) );
filterAlongSecond = fspecial( 'gaussian', [1 maskSize(2)], sigmasInPoints(2) ); 

filter2d = filterAlongFirst * filterAlongSecond;

dataFiltered = data;
dataFiltered(:,:) = imfilter( data.Values, filter2d, 'symmetric' );

end