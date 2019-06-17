classdef PolychromaticSource
    % PolychromaticSource Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        position
        amplitude
        frequency
        phase
    end
    
    properties ( Dependent=true )
        totalComponents
    end
    
    methods
        function source = PolychromaticSource( position, amplitudes, frequencies, phases )
            input = { amplitudes, frequencies, phases };
            assert( all( cellfun( @IsNumericVector, input ) ) ...
                && IsConstantArray( cellfun( @length, input ) ) ...
                && IsNumericVector( position ) && length( position ) == 3 );
            source.amplitude = amplitudes;
            source.frequency = frequencies;
            source.phase = phases;
            source.position = position;
        end
        
        function totalComps = get.totalComponents( source )
            totalComps = length( source.amplitude );
        end
        
    end
    
end

