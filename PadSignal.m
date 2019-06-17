function [ PaddedAxis, PaddedSignal ] = PadSignal( Axis, Signal, NewMinValue, NewMaxValue )

% This function preserves the step on the absciss. Therefore the new
% MaxValue may not be exactly what's prescribed

PaddingPointsOnLeft = fliplr( Axis.MinValue : -Axis.Step : NewMinValue );
TotalPaddingOnLeft = length( PaddingPointsOnLeft );

PaddingPointsOnRight = Axis.MaxValue : Axis.Step : NewMaxValue;
TotalPaddingOnRight = length( PaddingPointsOnRight );

PaddedAxis = GraphAxis( [ PaddingPointsOnLeft( 1 : end - 1 ), Axis.Locations, PaddingPointsOnRight( 2 : end ) ], Axis.Name, Axis.Units );
PaddedSignal = [ Signal( 1 ) * ones( 1, TotalPaddingOnLeft - 1 ), Signal, Signal( end ) * ones( 1, TotalPaddingOnRight - 1 ) ];

end