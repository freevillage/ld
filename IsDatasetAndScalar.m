function yesno = IsDatasetAndScalar( data1, data2 )

% The first parameter must be a dataset, and the second one must be either
% a dataset of the same size or a scalar

yesno = IsDataset( data1 ) ...
    && ( ( IsDataset( data2 ) && IsEqualSize( data1, data2 ) ) || IsNumericScalar( data2 ) );

end