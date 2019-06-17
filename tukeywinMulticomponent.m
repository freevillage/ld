function window = tukeywinMulticomponent( subset, totalPoints, taperRatio )

window = zeros( totalPoints, 1 );

[ totalComponents, begComponent, endComponent ] = findConnectedComponents( subset, totalPoints );

for indexComponent = 1 : totalComponents
    begCurrentComponent = begComponent( indexComponent );
    endCurrentComponent = endComponent( indexComponent );
    lengthCurrentComponent = endCurrentComponent - begCurrentComponent + 1;
    
    window( begCurrentComponent : endCurrentComponent ) = tukeywin( lengthCurrentComponent, taperRatio );
end

end