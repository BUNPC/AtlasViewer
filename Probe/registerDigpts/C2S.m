function [r, theta, phi] = C2S(XYZ)

% [r, theta, phi] = C2S(XYZ);
%
% ref.
% http://en.wikipedia.org/wiki/Spherical_coordinates
% http://en.wikipedia.org/wiki/Atan2

r = sum((XYZ .^ 2), 2) .^ 0.5;
theta = atan2(XYZ(:,2), XYZ(:,1));
phi = acos(XYZ(:,3) ./ r);
