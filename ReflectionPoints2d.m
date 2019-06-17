function [reflectionOffset, reflectionDepth] = ReflectionPoints2d( sourceOffset, sourceDepth, receiverOffset, receiverDepth, reflectorOffset, reflectorDepth, reflectorDip )

%% Parse input variables and check for consistency
%totalInputs = size( sourceLocation, 1 );
% assert( ...
%     isequal( size( sourceLocation ), [totalInputs 2] ) && ...
%     isequal( size( receiverLocation ), [totalInputs 2] ) && ...
%     isequal( size( reflectorLocation ), [totalInputs 2] ) && ...
%     isvector( reflectorDip ) && length( reflectorDip ) == totalInputs );



reflectorAngle = reflectorDip;

sinesOfAngle  = sin( reflectorAngle );
cosineOfAngle = cos( reflectorAngle );

%% Shift and rotate so that reflector is flat and based at origin

sourceOffsetNew = ( sourceOffset - reflectorOffset ) .* cosineOfAngle...
                 + ( sourceDepth  - reflectorDepth  ) .* sinesOfAngle;
             
sourceDepthNew  = - ( sourceOffset - reflectorOffset ) .* sinesOfAngle...
                   + ( sourceDepth  - reflectorDepth  ) .* cosineOfAngle;
               
receiverOffsetNew = ( receiverOffset - reflectorOffset ) .* cosineOfAngle...
                   + ( receiverDepth  - reflectorDepth  ) .* sinesOfAngle;
               
receiverDepthNew  = - ( receiverOffset - reflectorOffset ) .* sinesOfAngle...
                     + ( receiverDepth  - reflectorDepth  ) .* cosineOfAngle;               

%% Compute reflection points in the new coordinate system

reflectionOffsetNew = ( receiverOffsetNew .* sourceDepthNew + sourceOffsetNew .* receiverDepthNew ) ...
                    ./ ( sourceDepthNew + receiverDepthNew );
                
reflectionDepthNew  = zeros( size( reflectionOffsetNew ) );

%% Compute receiver image in new coordinates
% 
% mirrorOffsetNew = 2 * reflectionOffsetNew - receiverOffsetNew;
% mirrorDepthNew  = receiverDepthNew;

%% Change the coordinates of the reflection points to the old coordinate
% system

reflectionOffset = reflectionOffsetNew .* cosineOfAngle - reflectionDepthNew .* sinesOfAngle...
                 + reflectorOffset;
              
reflectionDepth  = reflectionOffsetNew .* sinesOfAngle   + reflectionDepthNew .* cosineOfAngle...
                 + reflectorDepth;
              
%% Change coordinates of mirrors back to the old coordinate system
% 
% mirrorOffset = mirrorOffsetNew .* cosineOfAngle - mirrorDepthNew .* sinesOfAngle ...
%              + reflectorOffset;
% 
% mirrorDepth  = mirrorOffsetNew .* sinesOfAngle + mirrorDepthNew .* cosineOfAngle ...
%              + reflectorDepth;
% 
%               
% %% Combine the answer in 
% 
% reflectionPoint  = [ reflectionOffset, reflectionDepth ];
% 
% receiverMirror = [ mirrorOffset, mirrorDepth ];

end