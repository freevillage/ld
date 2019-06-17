function methodNames = GetMethodNamesFromDescriptions( methodDescriptions )

% totalMethods = length( methodDescriptions );
% methodNames  = cell( 1, totalMethods );
% 
% for iMethod = 1 : totalMethods
%     thisMethod = methodDescriptions{iMethod};
%     methodNames{iMethod} = thisMethod{2};
% end

methodNames = cellfun( @(x) (x{2}), methodDescriptions, ...
    'UniformOutput', false );


end