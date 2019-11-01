function theta = angleBetweenVectors(u,v)

theta = [];

ndims_u = size(u,2);
ndims_v = size(v,2);

if ndims_u ~= ndims_v
    return;
end

ndims = ndims_u;

if ndims ~= 2 & ndims~=3
    return;
end

if ndims==2
    theta = rad2deg( acos( dot(u,v) / (sqrt(u(1)^2 + u(2)^2) * sqrt(v(1)^2 + v(2)^2)) ) );
elseif ndims==3
    theta = rad2deg( acos( dot(u,v) / (sqrt(u(1)^2 + u(2)^2 + u(3)^2) * sqrt(v(1)^2 + v(2)^2 + v(3)^2)) ) );
end

