function VelocityField = DippingLayers2D( AxisX, AxisZ, BasePointX, BasePointZ, DippingAngle, LayerThickness, LayerVelocity,DiffrX,StepHeight )

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

% Put a step on the reflector

VelocityField = VelocityField';

[TotRow TotCol] = size(VelocityField);

% Step location and height in terms of matrix elements.
OffsetCol = ceil((TotCol/( AxisX.MaxValue - AxisX.MinValue ))*DiffrX);
OffsetRow = ceil((TotRow/( AxisZ.MaxValue - AxisZ.MinValue ))*(StepHeight + LayerThickness(1)));

% Insert step on the VelocityField.
for ColNum = OffsetCol:TotCol
    VelocityField(:,ColNum) = LayerVelocity(1).*ones(TotRow,1);
end

for RowNum =  OffsetRow:TotRow
    VelocityField(RowNum,:) = LayerVelocity(2).*ones(1,TotCol);
end
VelocityField = VelocityField';
end