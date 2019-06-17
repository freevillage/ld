function yesno = IsColon( input )

yesno = ischar( input ) && strcmp( input, ':' );

end