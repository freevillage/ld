function Vq = Interp1Complex(X,V,Xq,varargin)

Vq = interp1(X,real(V),Xq,varargin{:}) ...
    + 1i * interp1(X,imag(V),Xq,varargin{:});

end