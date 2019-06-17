function yesno = IsIncreasing( array )

yesno = all( diff( ToColumn( array ) ) >= 0 );

end