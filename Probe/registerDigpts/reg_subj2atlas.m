function [atlas_optodes, transformed_p1020] = reg_subj2atlas(method, subj, atlas)
% NAME
%  reg_subj2atlas
%
% SYNOPSIS
%  >> [atlas_optodes, transformed_p1020] = reg_subj2atlas(method, subj, atlas);  
% 
% INPUTS
%  method ... Registration method. 'canonical' or 'anchor' must be chosen.
%  # If 'canonical' is chosen as a method, subj must have these fields.  
%  subj ... Digitized points on subject's head.
%           subj.p1020 ... reference points [nx3] (n is at least 4)
%           subj.l1020 ... reference label related to p1020 {nx1}
%           subj.optodes ... optode positions on subject's head [ox3]
%           See sample/subj_data1.mat.  
%  # If 'anchor' is chosen as a method, subj must have these fields.  
%  subj ... Digitized points on subject's head.
%           subj.p1020 ... reference points [nx3] (n is at least 3: Nz, AL and AR)
%           subj.l1020 ... reference label related to p1020 {nx1}
%           subj.optodes ... optode positions on subject's head [ox3]
%           subj.anchor ... anchor point around top of the head
%           See sample/subj_data1.mat.  
%  atlas ... Atlas head information which contains
%            atlas.head ... Atlas head surface points [px3]
%            atlas.p1020 ... reference points [qx3]
%            atlas.l1020 ... reference label related to p1020 {qx1}
%   
% OUTPUTS
%  atlas_optodes ... transformed optode in atlas space by affine transformation.
%  transformed_p1020 ... transformed reference points in atlas space.
%
% REFS
%  Spatial registration of multichannel multi-subject fNIRS data to MNI
%  space without MRI.  
%  http://www.ncbi.nlm.nih.gov/pubmed/15979346
%  
%  Stable and convenient spatial registration of stand-alone NIRS data
%  through anchor-based probabilistic registration.
%  http://www.ncbi.nlm.nih.gov/pubmed/22062377

switch upper(method)

  % ---------------------------
  % Canonical registration case
  % ---------------------------
  
 case 'CANONICAL'
  p1020 = nan(size(subj.p1020, 1), size(subj.p1020, 2));
  ref_atlas.p1020 = p1020;
  uatlas.l1020 = upper(atlas.l1020); % for ease of search

  for n = 1:length(subj.l1020)
    target = subj.l1020{n};
    [TF, LOC] = ismember(upper(target), uatlas.l1020);
    ref_atlas.p1020(n, :) = atlas.p1020(LOC, :);
  end
  
  ref_atlas.p1020(:, 4) = 1;
  subj.p1020(:, 4) = 1;
  w = subj.p1020 \ ref_atlas.p1020; % get transformation matrix

  % ------------------------
  % Anchor registration case
  % ------------------------
  
 case 'ANCHOR'
  p1020 = nan(size(subj.p1020, 1), size(subj.p1020, 2));
  ref_atlas.p1020 = p1020;
  uatlas.l1020 = upper(atlas.l1020); % for ease of search

  for n = 1:length(subj.l1020)
    target = subj.l1020{n};
    [TF, LOC] = ismember(upper(target), uatlas.l1020);
    ref_atlas.p1020(n, :) = atlas.p1020(LOC, :);
  end

  subj.AR = subj.p1020(strmatch(upper('AR'), upper(subj.l1020)), 1:3);
  subj.AL = subj.p1020(strmatch(upper('AL'), upper(subj.l1020)), 1:3);
  subj.Nz = subj.p1020(strmatch(upper('Nz'), upper(subj.l1020)), 1:3);

  atlas.AR = atlas.p1020(strmatch(upper('AR'), upper(atlas.l1020)), 1:3);
  atlas.AL = atlas.p1020(strmatch(upper('AL'), upper(atlas.l1020)), 1:3);
  atlas.Nz = atlas.p1020(strmatch(upper('Nz'), upper(atlas.l1020)), 1:3);

  atlas_anchor = get_atlas_anchor(subj, atlas);

  subj_refp = [subj.p1020; subj.anchor]; subj_refp(:, 4) = 1;
  atlas_refp = [ref_atlas.p1020; atlas_anchor]; atlas_refp(:, 4) = 1;

  subj.p1020(:, 4) = 1;
  w = subj_refp \ atlas_refp;
end

transformed_p1020 = subj.p1020 * w; % 10/20 points in atlas space
transformed_p1020(:, 4) = [];

subj.optodes(:, 4) = 1;
atlas_optodes = subj.optodes * w; % optodes in atlas space
atlas_optodes(:, 4) = [];



function atlas_anchor = get_atlas_anchor(subj, atlas)

[PAr, PBr, PCr, Anchor, InvMat] = ...
    ar_AlignPoints(subj.AR, subj.AL, subj.Nz, subj.anchor);
[R, Theta, Phi] = C2S(Anchor);
TargetT = Theta; % Theta of anchor point on the synthesized head.
TargetP = Phi; % Phi of anchor point on the synthesized head.

[PAr, PBr, PCr, Hr, InvMat] = ...
    ar_AlignPoints(atlas.AR, atlas.AL, atlas.Nz, atlas.head);

% Temporarily I added this routine to tolerate LIA or LAS orientation.
if length(find(Hr(:, 3) > 0)) < length(find(Hr(:, 3) < 0))
  Flipped = true;
  FlipMat = [-1 0  0 0;
              0 1  0 0;
              0 0 -1 0;
              0 0  0 1];
  Hr(:, 4) = 1;
  Hr = Hr * FlipMat;
  Hr(:, 4) = [];
end
  
nanI = find(isnan(Hr(:,3)));
Hr(nanI, :) = [];
atlas.head(nanI, :) = [];

Under0I = find(Hr(:, 3) < 0);
Hr(Under0I, :) = [];
atlas.head(Under0I, :) = [];

[R, Theta, Phi] = C2S(Hr);

BestP = [];
for n = 1:size(Anchor, 1)
  [V, I] = min(sqrt((Theta - TargetT(n)) .^ 2) + ...
               sqrt((Phi   - TargetP(n)) .^ 2));
  thisBestP = atlas.head(I, :);
  BestP(n, :) = thisBestP;
end

atlas_anchor = BestP;
