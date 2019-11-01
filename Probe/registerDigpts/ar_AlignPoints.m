function [PArTR, PBrTR, PCrTR, AnchorTR, InvMat] = ar_AlignPoints(PAr, PBr, PCr, Anchor)

% Notes.

% PAr(RPA) [0,    0,    0]
% PBr(LPA) [x_LPA, 0,    0]
% PCr(Nz) [x_RPA, y_RPA, 0]

% In the 'ar_AlignPoints' function, these points will be converted to
% PAr(RPA) [x,    0,        0]
% PBr(LPA) [-x,   0,        0]
% PCr(Nz) [x_Nz, y_Nz(>0), 0]


[aligned_p, TRmat, AnchorTR] = my_align_3p([PCr; PAr; PBr], Anchor);
PArTR = aligned_p(2, 1:3); % aligned RPA
PBrTR = aligned_p(3, 1:3); % aligned LPA
PCrTR = aligned_p(1, 1:3); % aligned Nz
InvMat = inv(TRmat);



function [aligned_p, TRmat, aligned_ext_p] = my_align_3p(p, ext_p)

% Usage.
%  Align 3 reference points, Nz, RPA and LPA to my favorite coordinate
%  system by the combination of translation and several rotations.
%  [aligned_p, TRmat] = my_align_3p(p);
%  Where aligned_p is aligned 3 points, TRmat is the conversion matrix.
%  If you have other points you want to align, just define them as 2nd argin.
%  [aligned_p, TRmat, aligned_ext_p] = my_align_3p(p, ext_p);
%  aligned_ext_p is the result of 'ext_p * TRmat'.
%  
% Input.
%  p ... <3x3 matrix>
%  Nz [x1, y1, z1]
%  RPA [x2, y2, y2]
%  LPA [x3, y3, z3]
%
% Output.
%  aligned_p ... <3x3 matrix>
%  Nz [x1 * TRmat, y1 * TRmat, 0]
%  RPA [x2 * TRmat,          0, 0]
%  LPA [x3 * TRmat,          0, 0]
%  
% e.g.,
%  >> cd_17heads;
%  >> load NFRI_R17;
%  >> p = NFRI_R17(1).input([1, 3, 4], :); % Nz; RPA; LPA;
%  >> ext_p = NFRI_R17(1).head;
%  >> [aligned_p, TRmat, aligned_ext_p] = my_align_3p(p, ext_p);
%  >> figure; hold on
%  >> plot4(aligned_p, 'k.', 10); plot4(aligned_ext_p, 'c.', 1);
%  >> axis equal vis3d;
  

[T_p, T] = calcT(p);

% p                   T_p
%
% Nz [x1, y1, z1]     Nz [x1-(x2+x3)/2, y1-(y2+y3)/2, z1-(z2+z3)/2]
% RPA [x2, y2, y2]  -> RPA [x2-(x2+x3)/2, y2-(y2+y3)/2, z2-(z2+z3)/2]
% LPA [x3, y3, z3]     LPA [x3-(x2+x3)/2, y3-(y2+y3)/2, z3-(z2+z3)/2]


[TR_p, TR]     = calcTR(T_p, T);

% T_p                       TR_p
%
% Nz [ x1',  y1',  z1']     Nz [ RotZ(x1'), RotZ(y1'),  RotZ(z1')]
% RPA [ x2',  y2',  z2']  -> RPA [ RotZ(x2'),         0,  RotZ(z2')]
% LPA [-x2', -y2', -z2']     LPA [RotZ(-x2'),         0, RotZ(-z2')]


[TRR_p, TRR]   = calcTRR(TR_p, TR);

% TR_p                        TRR_p
%
% Nz [ x1'', y1'',  z1'']     Nz [ RotY(x1''), RotY(y1''), RotY(z1'')]
% RPA [ x2'',    0,  z2'']  -> RPA [ RotY(x2''),          0,          0]
% LPA [-x2'',    0, -z2'']     LPA [RotY(-x2''),          0,          0]


[TRRR_p, TRRR] = calcTRRR(TRR_p, TRR);

% TRR_p                         TRRR_p
%
% Nz [ x1''', y1''', z1''']     Nz [ RotX(x1'''), RotX(y1'''), 0]
% RPA [ x2''',     0,     0]  -> RPA [ RotX(x2'''),           0, 0]
% LPA [-x2''',     0,     0]     LPA [RotX(-x2'''),           0, 0]


semifinal_p = TRRR_p;
semifinal_TRmat = TRRR;

% If y of Nz is negative, flip reference points aside X-axis.
if semifinal_p(1, 2) < 0
  [semifinal_p, flipXmat] = my_RotX(semifinal_p, pi);
  semifinal_TRmat = semifinal_TRmat * flipXmat;
end

% If x of RPA is negative (& LPA is positive), flip reference points aside Y-axis.
if semifinal_p(2, 1) < 0
  [semifinal_p, flipYmat] = my_RotY(semifinal_p, pi);
  semifinal_TRmat = semifinal_TRmat * flipYmat;  
end

aligned_p = semifinal_p;
TRmat = semifinal_TRmat;

if nargin == 2
  ext_p(:, 4) = 1;
  aligned_ext_p = ext_p * TRmat;
end



% -- sub functions --

function [T_p, T] = calcT(p)
  
  Nz = p(1, :);
  RPA = p(2, :);  
  LPA = p(3, :);
  
  C = (LPA + RPA) / 2;
  T = eye(4);
  T(4, :) = [-C 1];

  p(:, 4) = 1;
  T_p = p * T;

  
  
function [TR_p, TR] = calcTR(T_p, T)
  
  LPAxy = T_p(2, [1 2]);
  n_LPAxy = LPAxy / norm(LPAxy);
  sp = dot([1 0], n_LPAxy);

  LPAy = T_p(2, 2);
  if LPAy < 0
    rad = acos(sp);
  else
    rad = acos(-sp);
  end

  [TR_p, rotmatZ] = my_RotZ(T_p, rad);
  TR = T * rotmatZ;

  
  
function [TRR_p, TRR] = calcTRR(TR_p, TR)
  
  LPAxz = TR_p(2, [1 3]);
  n_LPAxz = LPAxz / norm(LPAxz);
  sp = dot([1 0], n_LPAxz);

  LPAz = TR_p(2, 3);
  if LPAz < 0
    rad = acos(-sp);
  else
    rad = acos(sp);
  end

  [TRR_p, rotmatX] = my_RotY(TR_p, rad);
  TRR = TR * rotmatX;

  
  
function [TRRR_p, TRRR] = calcTRRR(TRR_p, TRR)

  Nzyz = TRR_p(1, [2 3]);
  n_Nzyz = Nzyz / norm(Nzyz);
  sp = dot([1 0], n_Nzyz);

  Nzz = TRR_p(1, 3);
  if Nzz > 0
    rad = acos(-sp);
  else
    rad = acos(sp);
  end

  [TRRR_p, rotmatY] = my_RotX(TRR_p, rad);
  TRRR = TRR * rotmatY;

  
  
function [Output, RotMatX] = my_RotX(Mat, Angle)

% e.g.,
%  >> xyz = rand(3, 3);
%  >> [rotated_xyz, rotmat] = my_RotX(xyz, pi);
  
if size(Mat, 2) == 3,
  Mat(:, 4) = 1;
end
  
RotMatX= [ ...
    1 0           0          0;
    0 cos(Angle)  sin(Angle) 0;
    0 -sin(Angle) cos(Angle) 0;
    0 0           0          1];

Output = Mat * RotMatX;



function [Output, RotMatY] = my_RotY(Mat, Angle)

% e.g.,
%  >> xyz = rand(3, 3);
%  >> [rotated_xyz, rotmat] = my_RotY(xyz, pi);

if size(Mat, 2) == 3,
  Mat(:, 4) = 1;
end

RotMatY = [ ...
    cos(Angle) 0 -sin(Angle) 0;
    0          1 0           0;
    sin(Angle) 0 cos(Angle)  0;
    0          0 0           1];

Output = Mat * RotMatY;



function [Output, RotMatZ] = my_RotZ(Mat, Angle)

% e.g.,
%  >> xyz = rand(3, 3);
%  >> [rotated_xyz, rotmat] = my_RotZ(xyz, pi);

if size(Mat, 2) == 3,
  Mat(:, 4) = 1;
end

RotMatZ = [ ...
    cos(Angle)  sin(Angle) 0 0;
    -sin(Angle) cos(Angle) 0 0;
    0           0          1 0;
    0           0          0 1];

Output = Mat * RotMatZ;
