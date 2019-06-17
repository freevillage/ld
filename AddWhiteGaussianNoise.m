function noisySignal = AddWhiteGaussianNoise( signal, varargin )

noisySignal = reshape( awgn( ToColumn( signal ), varargin{:} ), size( signal ) );

end