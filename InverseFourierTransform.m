function data = InverseFourierTransform( varargin )

inputs = varargin;
inputs{1} = conj( inputs{1} ); % first input is dataset (function)
data = conj( FourierTransform( inputs{:} ) );

end