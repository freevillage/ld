function VelocityField = DippingLayers( AxisX, AxisZ, BasePointX, BasePointZ, DippingAngle, LayerThickness, LayerVelocity )

% Assume that the dipping angle is between 0 and pi/2
if( or( DippingAngle < 0, DippingAngle > pi / 2 ) )
    error( 'The dipping angle should be between 0 and pi/2 radians' );
end

DippingAngle = - DippingAngle;

% Compute the total number of layers
TotalLayers = length( LayerThickness );

LayerBasePointX = BasePointX * ones( TotalLayers, 1 );
LayerBasePointZ = BasePointZ + [ 1, cumsum( LayerThickness( 1 : end - 1 ) ) ] / cos( DippingAngle );

% Create the domain
[ XGrid, ZGrid ] = ndgrid( AxisX.Locations, AxisZ.Locations );
VelocityField = zeros( size( XGrid ) );

% Go through each layer except the last and assign its velocity to corresponding points
for LayerNumber = 1 : TotalLayers - 1
    InCurrentLayer = find( and( sin( DippingAngle ) * ( XGrid - LayerBasePointX( LayerNumber ) ) - ...
                                cos( DippingAngle ) * ( ZGrid - LayerBasePointZ( LayerNumber ) ) < 0, ...
                                sin( DippingAngle ) * ( XGrid - LayerBasePointX( LayerNumber + 1 ) ) - ...
                                cos( DippingAngle ) * ( ZGrid - LayerBasePointZ( LayerNumber + 1 ) ) >= 0 ) );
    VelocityField( InCurrentLayer ) = LayerVelocity( LayerNumber );
end

% Last layer has infinite thickness and hence it is treated separately
LayerNumber = TotalLayers;
InCurrentLayer = find( sin( DippingAngle ) * ( XGrid - LayerBasePointX( LayerNumber ) ) - ...
                       cos( DippingAngle ) * ( ZGrid - LayerBasePointZ( LayerNumber ) ) < 0 );
VelocityField( InCurrentLayer ) = LayerVelocity( LayerNumber ); 


end

