function directions = EspritDoa( arrayData, totalMonochromeComponents, sourceFrequency, arraySpacing )

directions = asin( LightSpeed * EspritInversion( arrayData, totalMonochromeComponents ) / ( 2*sourceFrequency*arraySpacing ) );

end % of function