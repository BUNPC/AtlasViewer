function r = vrrotvec_copy(a, b, options)
%VRROTVEC Calculate a rotation between two vectors.
%   R = VRROTVEC(A, B) calculates a rotation needed to transform 
%   a 3d vector A to a 3d vector B.
%
%   R = VRROTVEC(A, B, OPTIONS) calculates the rotation with the default 
%   algorithm parameters replaced by values defined in the structure
%   OPTIONS.
%
%   The OPTIONS structure contains the following parameters:
%
%     'epsilon'
%        Minimum value to treat a number as zero. 
%        Default value of 'epsilon' is 1e-12.
%
%   The result R is a 4-element axis-angle rotation row vector.
%   First three elements specify the rotation axis, the last element
%   defines the angle of rotation.
%
%   See also VRROTVEC2MAT, VRROTMAT2VEC, VRORI2DIR, VRDIR2ORI.

%   Copyright 1998-2011 HUMUSOFT s.r.o. and The MathWorks, Inc.

% test input arguments
narginchk(2, 3);

if any(~isreal(a) || ~isnumeric(a))
  error(message('sl3d:vrdirorirot:argnotreal'));
end

if (length(a) ~= 3)
  error(message('sl3d:vrdirorirot:argbaddim', 3));
end

if any(~isreal(b) || ~isnumeric(b))
  error(message('sl3d:vrdirorirot:argnotreal'));
end

if (length(b) ~= 3)
  error(message('sl3d:vrdirorirot:argbaddim', 3));
end

if nargin == 2
  % default options values
  epsilon = 1e-12;
else
  if ~isstruct(options)
     error(message('sl3d:vrdirorirot:optsnotstruct'));
  else
    % check / read the 'epsilon' option
    if ~isfield(options,'epsilon') 
      error(message('sl3d:vrdirorirot:optsfieldnameinvalid')); 
    elseif (~isreal(options.epsilon) || ~isnumeric(options.epsilon) || options.epsilon < 0)
      error(message('sl3d:vrdirorirot:optsfieldvalueinvalid'));   
    else
      epsilon = options.epsilon;
    end
  end
end

% compute the rotation, vectors must be normalized
an = sl3dnormalize_copy(a, epsilon);
bn = sl3dnormalize_copy(b, epsilon);

% test for zero input argument magnitude after normalize to take epsilon 
% into account
if (~any(an) || ~any(bn))
  error(message('sl3d:vrdirorirot:argzeromagnitude'));
end

ax = sl3dnormalize_copy(cross(an, bn), epsilon);
% min to eliminate possible rounding errors that can lead to dot product >1
angle = acos(min(dot(an, bn), 1));

% if cross(an, bn) is zero, vectors are parallel (angle = 0) or antiparallel
% (angle = pi). In both cases it is necessary to provide a valid axis. Let's
% select one that satisfies both cases - an axis that is perpendicular to
% both vectors. We find this vector by cross product of the first vector 
% with the "least aligned" basis vector.
if ~any(ax)
    absa = abs(an);
    [~, mind] = min(absa);
    c = zeros(1,3);
    c(mind) = 1;
    ax = sl3dnormalize_copy(cross(an, c), epsilon);
end

% Be tolerant to column vector arguments, produce a row vector
r = [ax(:)' angle];
