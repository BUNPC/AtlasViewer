function b = isintegerarr(x)

% Determine if all the values in array x are integers.
b = all(floor(x(:)) == x(:));

