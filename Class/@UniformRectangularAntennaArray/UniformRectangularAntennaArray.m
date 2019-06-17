classdef UniformRectangularAntennaArray
   
    properties
        totalRows % Ny
        totalCols % Nx
        rowSpacing % dy
        colSpacing % dx
    end
    
    properties( Dependent = true )
        size
        totalAntennas
        antennaGeometry
        xGrid
        yGrid
    end
    
    methods
        
        function ura = UniformRectangularAntennaArray( dimensions, spacing )
            ura.totalCols = dimensions(1);
            ura.totalRows = dimensions(2);
            ura.colSpacing = spacing(1);
            ura.rowSpacing = spacing(2);
        end
        
        function totalAnt = get.totalAntennas( ura )
            totalAnt = ura.totalRows * ura.totalCols;
        end
        
        function uraSize = get.size( ura )
            assert( ura.totalRows > 1 && ura.totalCols > 1 )
            uraSize = [ ...
                ura.rowSpacing * ( ura.totalRows - 1 ), ...
                ura.colSpacing * ( ura.totalCols - 1 ) ];
        end
        
        function xgrid = get.xGrid( ura )
            xgrid = linspace( -ura.size(1)/2, ura.size(1)/2, ura.totalCols );
        end
        
        function ygrid = get.yGrid( ura )
            ygrid = linspace( -ura.size(2)/2, ura.size(2)/2, ura.totalRows );
        end
        
        function antennaPos = get.antennaGeometry( ura )
           [ xMesh, yMesh ] = ndgrid( ura.xGrid, ura.yGrid );
           antennaPos = nan( [ 2, size( xMesh ) ] );
           antennaPos(1,:,:) = xMesh;
           antennaPos(2,:,:) = yMesh;
        end
        
        function disp( ura )
            figure
            antennaPositionsReshaped = reshape( ura.antennaGeometry, 2, ura.totalAntennas );
            plot( antennaPositionsReshaped(1,:), antennaPositionsReshaped(2,:), ...
                'g^', ...
                'MarkerFaceColor', 'g' ...
                );
            set( gca, ...
                'XTick', ura.xGrid, ...
                'YTick', ura.yGrid ...
                );
            axis( [ MinMaxExpanded( ura.xGrid ), MinMaxExpanded( ura.yGrid ) ] )
            grid on
            title( inputname( 1 ) )
            xlabel( 'x' ), ylabel( 'y' )
            daspect( [ 1 1 1 ] )

        end
        
    end
    
end

