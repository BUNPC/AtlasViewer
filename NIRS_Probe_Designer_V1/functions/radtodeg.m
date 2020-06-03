function angleInDegrees = radtodeg(angleInRadians)
% RADTODEG Convert angles from radians to degrees
%
%   angleInDegrees = RADTODEG(angleInRadians) converts angle units from
%   radians to degrees.
%
%   See also: RAD2DEG

% Copyright 2009-2015 The MathWorks, Inc.

angleInDegrees = (180/pi) * angleInRadians;
