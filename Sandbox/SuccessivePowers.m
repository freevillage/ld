function aToPowers = SuccessivePowers( a, powerMax )

aToPowers = cumprod( repmat( a, [1 powerMax] ) );

end