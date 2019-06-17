classdef MovingURA
    %MOVINGURA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        array
        positionFcn
        rotationXFcn
        rotationYFcn
        rotationZFcn
    end
    
    methods
        
        function movingUra = MovingURA( array, positionFcn, rotationXFcn, rotationYFcn, rotationZFcn )
            assert( isa( array, 'UniformRectangularAntennaArray' ) );
            assert( all( cellfun( @(f) isa( f, 'function_handle' ), ...
                { positionFcn, rotationXFcn, rotationYFcn, rotationZFcn } ) ) );
            
            movingUra.array = array;
            movingUra.positionFcn = positionFcn;
            movingUra.rotationXFcn = rotationXFcn;
            movingUra.rotationYFcn = rotationYFcn;
            movingUra.rotationZFcn = rotationZFcn;
        end
        
    end
    
end

