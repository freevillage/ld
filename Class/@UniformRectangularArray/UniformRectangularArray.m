classdef UniformRectangularArray
   
    properties
        Nx % Nx
        Ny % Ny
        lx
        ly
    end
    
    properties( Dependent = true )
        dx
        dy
    end
    
    methods
        
        function ura = UniformRectangularArray( arraySize, arrayDimensions )
            ura.Nx = arraySize(1);
            ura.Ny = arraySize(2);
            ura.lx = arrayDimensions(1);
            ura.ly = arrayDimensions(2);
        end
        
    end
    
end

