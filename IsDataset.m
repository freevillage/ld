function yesno = IsDataset( input )
%ISDATASET(A) returns true if A is of class Dataset and false
%otherwise
%
%Examples:
%   ISDATASET(Dataset(ones(100))) returns true
%   ISDATASET(ones(100)) returns false
%
% See also:
%   ISA

% Copyright 2013/1/20 Oleg V. Poliannikov
% Oleg.Poliannikov@gmail.com

yesno = isa( input, 'DatasetNd' );

end

