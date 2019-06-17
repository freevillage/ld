function DisplayGather( Gather )

Gather = squeeze( Gather );

switch ndims( Gather )
    case 2
        imagesc( Gather );
        ColormapBlueRed;
        colorbar;
    case 1
        plot( Gather );
    otherwise
        error( 'DisplayGather:DimensionTooHigh', ...
            'Gather must be one or two-dimensional to be displayed' );
end

end % of DisplayGather