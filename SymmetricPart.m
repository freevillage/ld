function [ symmetricPart, antisymmetricPart ] = SymmetricPart( matrix )
%SymmetricPart(A) returns the symmetric part of the matrix A
%
%[S,AS]=SymmetricPart(A) returns the symmetric and antisymmetric part of A

symmetricPart = 0.5 * ( matrix + matrix.' );
antisymmetricPart = matrix - symmetricPart;

end