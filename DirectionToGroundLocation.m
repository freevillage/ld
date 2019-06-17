function [ x0, y0 ] = DirectionToGroundLocation( arrayPosition, alpha, beta, gamma, thetaX, thetaY )

rotationMatrix = RotationMatrix( alpha, beta, gamma );
xAxisRotated = rotationMatrix( :, 1 );
yAxisRotated = rotationMatrix( :, 2 );

x1 = xAxisRotated(1);
x2 = xAxisRotated(2);
x3 = xAxisRotated(3);

y1 = yAxisRotated(1);
y2 = yAxisRotated(2);
y3 = yAxisRotated(3);

c1 = sin( thetaX );
c2 = sin( thetaY );

z3 = -arrayPosition(3);

vx1 =   (z3*(c2^2*x1*x3 - x1*x3*y2^2 + c1^2*y1*y3 - x2^2*y1*y3 - c1*c2*(x3*y1 + x1*y3) + x2*y2*(x3*y1 + x1*y3) + ...
           sqrt(-(c2^2*(x1^2 + x2^2 + x3^2)) + x2^2*y1^2 + x3^2*y1^2 - 2*x1*x2*y1*y2 + x1^2*y2^2 + x3^2*y2^2 - 2*x3*(x1*y1 + x2*y2)*y3 + ...
              (x1^2 + x2^2)*y3^2 + 2*c1*c2*(x1*y1 + x2*y2 + x3*y3) - c1^2*(y1^2 + y2^2 + y3^2))*abs(c2*x2 - c1*y2)))/...
       (c2^2*(x1^2 + x2^2) - (x2*y1 - x1*y2)^2 - 2*c1*c2*(x1*y1 + x2*y2) + c1^2*(y1^2 + y2^2));
     
vx2 =         -((z3*(-(c2^2*x1*x3) + x1*x3*y2^2 - c1^2*y1*y3 + x2^2*y1*y3 + c1*c2*(x3*y1 + x1*y3) - x2*y2*(x3*y1 + x1*y3) + ...
             sqrt(-(c2^2*(x1^2 + x2^2 + x3^2)) + x2^2*y1^2 + x3^2*y1^2 - 2*x1*x2*y1*y2 + x1^2*y2^2 + x3^2*y2^2 - 2*x3*(x1*y1 + x2*y2)*y3 + ...
                (x1^2 + x2^2)*y3^2 + 2*c1*c2*(x1*y1 + x2*y2 + x3*y3) - c1^2*(y1^2 + y2^2 + y3^2))*abs(c2*x2 - c1*y2)))/...
         (c2^2*(x1^2 + x2^2) - (x2*y1 - x1*y2)^2 - 2*c1*c2*(x1*y1 + x2*y2) + c1^2*(y1^2 + y2^2)));

     
vy1 =         ((c2*x2 - c1*y2)*(c2^2*x2*x3 + x2*y1*(-(x3*y1) + x1*y3) + y2*(x1*x3*y1 + c1^2*y3 - x1^2*y3) - c1*c2*(x3*y2 + x2*y3))*z3 + ...
         (-(c2*x1) + c1*y1)*sqrt(-(c2^2*(x1^2 + x2^2 + x3^2)) + x2^2*y1^2 + x3^2*y1^2 - 2*x1*x2*y1*y2 + x1^2*y2^2 + x3^2*y2^2 - 2*x3*(x1*y1 + x2*y2)*y3 + ...
            (x1^2 + x2^2)*y3^2 + 2*c1*c2*(x1*y1 + x2*y2 + x3*y3) - c1^2*(y1^2 + y2^2 + y3^2))*z3*abs(c2*x2 - c1*y2))/...
       ((c2*x2 - c1*y2)*(c2^2*(x1^2 + x2^2) - (x2*y1 - x1*y2)^2 - 2*c1*c2*(x1*y1 + x2*y2) + c1^2*(y1^2 + y2^2)));
     
vy2 =            ((c2*x2 - c1*y2)*(c2^2*x2*x3 + x2*y1*(-(x3*y1) + x1*y3) + y2*(x1*x3*y1 + c1^2*y3 - x1^2*y3) - c1*c2*(x3*y2 + x2*y3))*z3 + ...
         (c2*x1 - c1*y1)*sqrt(-(c2^2*(x1^2 + x2^2 + x3^2)) + x2^2*y1^2 + x3^2*y1^2 - 2*x1*x2*y1*y2 + x1^2*y2^2 + x3^2*y2^2 - 2*x3*(x1*y1 + x2*y2)*y3 + ...
            (x1^2 + x2^2)*y3^2 + 2*c1*c2*(x1*y1 + x2*y2 + x3*y3) - c1^2*(y1^2 + y2^2 + y3^2))*z3*abs(c2*x2 - c1*y2))/...
       ((c2*x2 - c1*y2)*(c2^2*(x1^2 + x2^2) - (x2*y1 - x1*y2)^2 - 2*c1*c2*(x1*y1 + x2*y2) + c1^2*(y1^2 + y2^2)));  
     
     
     
     
x0 = arrayPosition(1) - [ vx1, vx2 ];
y0 = arrayPosition(2) - [ vy1, vy2 ];
     

    

end % of function 

