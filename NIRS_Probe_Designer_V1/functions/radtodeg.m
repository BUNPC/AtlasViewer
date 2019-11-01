function angleInDegrees = radtodeg(angleInRadians)
% RADTODEG Convert angles from radians to degrees
%
%   angleInDegrees = RADTODEG(angleInRadians) converts angle units from
%   radians to degrees.
%
%   Example
%   -------
%   % Convert a great-circle distance of 2500 kilometers to a spherical
%   % distance in degrees.
%   Re = 6371;  % Mean radius of Earth in km
%   sphericalDistance = radtodeg(2500 / Re)
%
%   See also: degtorad, fromDegrees, fromRadians, toDegrees, toRadians.

% Copyright 2009 The MathWorks, Inc.

angleInDegrees = (180/pi) * angleInRadians;
