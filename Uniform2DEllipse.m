function [ XSamples, YSamples ] = Uniform2DEllipse( EllipseX, EllipseY, EllipseAxis1, EllipseAxis2, EllipseAngle, TotalSamplesRequired )

TotalSamplesPerBatch = 2 * TotalSamplesRequired;
NeedMoreSamples = true;

MajorAxis = max( EllipseAxis1, EllipseAxis2 );
MinorAxis = min( EllipseAxis1, EllipseAxis2 );

XSamples = [];
YSamples = [];

while( NeedMoreSamples )
    XRectangle = Uniform( EllipseX - MajorAxis, EllipseX + MajorAxis, TotalSamplesPerBatch );
    YRectangle = Uniform( EllipseY - MajorAxis, EllipseY + MajorAxis, TotalSamplesPerBatch );
    
    IndicesInsideEllipse = IsInsideEllipse( XRectangle, YRectangle, EllipseX, EllipseY, MajorAxis, MinorAxis, EllipseAngle );
    
    XNewSamples = XRectangle( IndicesInsideEllipse );
    YNewSamples = YRectangle( IndicesInsideEllipse );
    
    XSamples = [ XSamples, XNewSamples ]; %#ok<AGROW>
    YSamples = [ YSamples, YNewSamples ]; %#ok<AGROW>
    
    if( length( XSamples ) >= TotalSampplesRequired )
        XSamples = XSamples( 1 : TotalSamplesRequired );
        YSamples = YSamples( 1 : TotalSamplesRequired );
        NeedMoreSamples = false;
    end
    
end % of while NeedMoreSamples

end % of function

function Flags = IsInsideEllipse( X, Y, EllipseX, EllipseY, MajorAxis, MinorAxis, EllipseAngle )

RotationMatrix = [ cos( EllipseAngle ), sin( EllipseAngle ) ; -sin( EllipseAngle ), cos( EllipseAngle ) ];
RotatedVector = RotationMatrix * [ X - EllipseX ; Y - EllipseY ];

RotatedX = RotatedVector( 1 );
RotatedY = RotatedVector( 2 );

Flags = ( ( RotatedX .^ 2 / MajorAxis ^ 2 + RotatedY .^ 2 / MinorAxis ^ 2 ) < 1 );

end % of IsInsideEllipse