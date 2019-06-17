function ArrivalTime = DirectArrival( Velocity, SourceX, SourceZ, ReceiverX, ReceiverZ )

TotalSources = length( SourceX );
TotalReceivers = length( ReceiverX );
ArrivalTime = zeros( TotalSources, TotalReceivers );

for SourceNumber = 1 : TotalSources
    for ReceiverNumber = 1 : TotalReceivers
        xs = SourceX( SourceNumber );
        zs = SourceZ( SourceNumber );
        xr = ReceiverX( ReceiverNumber );
        zr = ReceiverZ( ReceiverNumber );
        TotalDistance = sqrt( ( xs - xr ) ^ 2 + ( zs - zr ) ^ 2 );
        ArrivalTime( SourceNumber, ReceiverNumber ) = TotalDistance / Velocity;
    end
end

end