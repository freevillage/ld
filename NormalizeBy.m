function normalizedData = NormalizeBy( data, normFun )

normalizedData = data ./ normFun( data );

end