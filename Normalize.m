function datasetNormalized = Normalize( varargin )

[dataset, normFcn, desiredNorm] = ParseInput( varargin{:} );
datasetNormalized = dataset ./ normFcn( dataset ) .* desiredNorm;

end

function [dataset, normFcn, desiredNorm] = ParseInput( varargin )

totalInputs = nargin;

if totalInputs < 3
    desiredNorm = 1;
else
    desiredNorm = varargin{3};
    assert( IsNumericScalar( desiredNorm ) );
end

if totalInputs < 2
    normFcn = @norm;
else
    normDefinition = varargin{2};
    if isa( normDefinition, 'function_handle' )
        normFcn = normDefintiion;
    elseif IsProperNormLabel( normDefinition )
        normFcn = @(x) norm(x, normDefinition );
    end
end

assert( totalInputs >= 1 && IsDataset( varargin{1} ) );
dataset = varargin{1};

end

function yesno = IsProperNormLabel( label )

yesno = IsPositiveScalar( label ) || label == inf;

end