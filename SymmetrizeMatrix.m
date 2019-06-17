function matrixSymmetric = SymmetrizeMatrix( matrix )

matrixSymmetric = 0.5 * ( matrix + transpose( matrix ) );

end