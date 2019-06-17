function [ windowedAxis, windowedSignal ] = windowSignal( Axis, Signal, windowMin, windowMax )

windowIndex = find( ( Axis.Locations >= windowMin ) .* ( Axis.Locations <= windowMax ) );

windowedAxis = GraphAxis( Axis.Locations( windowIndex ) , Axis.Name, Axis.Units );
windowedSignal = Signal( windowIndex );

end % of windowSignal