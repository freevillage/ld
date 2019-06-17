function DisplayFigures( shouldDisplay )

assert( IsLogicalScalar( shouldDisplay ) );

if shouldDisplay
    set(0,'DefaultFigureVisible','on');
else
    set(0,'DefaultFigureVisible','off');
end

end