numberPeriods = round( logspace( 0, 5, 20 ) );
coeffs = logspace( 0, 5, 6 );


for j = 1 : 6
    for i = 1 : 20
        test_doa_resolution_fasttime( numberPeriods(i), coeffs(j) )
    end
    plot_doa_resolution_results
    
end