function Element = RandomElement( Array )

TotalElements = numel( Array );
RandomElementNumber = ceil( TotalElements * rand );
Element = Array( RandomElementNumber );

end