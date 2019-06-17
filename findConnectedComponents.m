function [ totalComponents, begComponent, endComponent ] = findConnectedComponents( subset, N )

space = 1 : N;
assert( all( ismember( subset, space ) ), ...
    'findConnectedComponents:notSubset', ...
    'subset must be a subset of 1:N' );

begComponent = zeros( 1, N );
endComponent = zeros( 1, N );

currentComponent = 0;

isPreviousElementInside = false;

for element = space
    if( ismember( element, subset ) )
        if( isPreviousElementInside )
            endComponent( currentComponent ) = element;
        else
            currentComponent = currentComponent + 1;
            begComponent( currentComponent ) = element;
            endComponent( currentComponent ) = element;
        end
        isPreviousElementInside = true;
    else
        isPreviousElementInside = false;
    end

end

totalComponents = currentComponent;

begComponent = begComponent( 1 : totalComponents );
endComponent = endComponent( 1 : totalComponents );
