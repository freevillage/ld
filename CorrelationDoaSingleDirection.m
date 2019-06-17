function directions = CorrelationDoaSingleDirection( arrayData, sourceFrequency, arraySpacing )

directions = asin( LightSpeed * CorrelationInversionSinglePhase( arrayData ) / ( 2*sourceFrequency*arraySpacing ) );

end % of function