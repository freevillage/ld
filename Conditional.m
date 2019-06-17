function y = Conditional(condition, x1, x2)
% CONDITIONAL M-file for C's ?: ternary operator
% Syntax: y = CONDITIONAL(condition, x1, x2)
%
% The elements of the output matrix will be set as:
% y(condition==true) = x1(condition==true)
% y(condition==false) = x2(condition==false)
%
% x1 and x2 can be function handles or matrices the same size as condition
%
% Example:
% x = -10:10;
% y = CONDITIONAL(x==0, @(z) 1, @(z) sin(x(z))./x(z));

y = nan(size(condition));
y(condition) = x1(condition);
y(~condition) = x2(~condition);