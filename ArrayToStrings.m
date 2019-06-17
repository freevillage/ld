function strings = ArrayToStrings( array )

strings = strtrim( transpose( cellstr( num2str( transpose( array ) ) ) ) );

end