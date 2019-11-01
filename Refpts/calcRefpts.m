function [refpts, err] = calcRefpts(refpts, head)

%
% USAGE:
%
%    [refpts, labels] = calcRefpts(refpts, head, labels)
%
% INPUTS:
%    
%    refpts  - A set of 5 landmark points in the order: Nz, Iz, RPA, LPA, Cz
%              where Cz is an initial guess (here referred to as Czi) 
%              marking some position close to the top of the head surface
%              passed as the first argument.
%
%    head    - Head volume or head vertices. 
%
%
% OUTPUTS:
%     
%    refpts     - A structure, (refpts.pos and refpts.labels), of 
%                 10-20, 10-10 or 10-5 reference points array and corresponding 
%                 ref points labels. 
%         or 
%
%    refpts     - 10-20, 10-10 or 10-5 reference points array
%    labels     - corresponding ref points labels.
%
%    Type of output will match the refpts input type.
% 
% DESCRIPTION:
%
%    User picks the reference points Nz, Iz, RPA, LPA and Cz (Cz can be less exact 
%    than the others, basically anywhere near the top/center of the head),
%    on a scan of the head.
%
%    *** NOTE *** this algorithm needs two conditions to work properly: 
%    a) the mesh density has to be reasonably high (a bit of trial and error),  
%    and b) the reference points should be on actual head voxels rather than 
%    air (or some other medium). 
%
% 
% EXAMPLE:
%
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   05/07/2009
%
% Modified by Jay Dubb to compute 10-20, 10-10, or 10-5 eeg points
% DATE:   04/18/2015
%
%

global DEBUG

DEBUG = 0;

if ~isstruct(head) && ndims(head)==2
    surf = head;
    vertices = surf;
    faces = [];
else
    if ~isstruct(head) && ndims(head)==3
        fv = isosurface(head,.9);
        fv.vertices = [fv.vertices(:,2) fv.vertices(:,1) fv.vertices(:,3)];
    elseif isstruct(head) && isfield(head,'img') && ~isempty(head.img)
        fv = isosurface(head.img,.9);
        fv.vertices = [fv.vertices(:,2) fv.vertices(:,1) fv.vertices(:,3)];
    elseif isstruct(head) && isfield(head,'mesh')
        fv = head.mesh;
        fv.vertices = genInterpSurface(fv);
    elseif isstruct(head) && isfield(head,'vertices')
        fv = head;
        fv.vertices = genInterpSurface(fv);
    end
    surf = fv;
    vertices = surf.vertices;
    faces = surf.faces;
end


% Check that we have enough vertices to do the work
if length(vertices)<1e5
    err = -1;
    return;
end


% Arg 2
pos    = refpts.pos;
labels = refpts.labels;
pos = nearest_point(vertices,pos);


% Arg 3 (optional)
if ~exist('labels','var')
    menu('ERROR: Labels not found. Cannot determine reference points.', 'OK');
    return;
end


% Find ref pts in pos
knz = find(strcmpi(labels,'nz'));
kiz = find(strcmpi(labels,'iz'));
krpa = find(strcmpi(labels,'rpa'));
klpa = find(strcmpi(labels,'lpa'));
kar = find(strcmpi(labels,'ar'));
kal = find(strcmpi(labels,'al'));
ka2 = find(strcmpi(labels,'a2'));
ka1 = find(strcmpi(labels,'a1'));
kcz = find(strcmpi(labels,'cz'));

% Error checking 
if isempty(knz) | isempty(kiz) | (isempty(klpa) & isempty(kal)) | (isempty(krpa) & isempty(kar)) | isempty(kcz)
    menu(sprintf('One or more landmarks are missing - unable to calculate %s pts.', refpts.eeg_system.selected),'OK');
    return;
end

Nz  = pos(knz,:);
Iz  = pos(kiz,:);
RPA = pos(krpa,:);
LPA = pos(klpa,:);
Czi = pos(kcz,:);

if DEBUG==1
    displayCurve(fv);
end


% Step sizes as a percentage of curve length
stepsizes(1) = 5;
stepsizes(2) = 12.5;
stepsizes(3) = 4.5455;

switch(refpts.eeg_system.ear_refpts_anatomy)
    case 'tragus'
        [eeg_curves, err] = calcRefpts0(surf, Nz, Iz, RPA, LPA, Czi, stepsizes);
    case 'preauricular'
        [eeg_curves, err] = calcRefpts1(surf, Nz, Iz, RPA, LPA, Czi, stepsizes);
    case 'lobule'
        [eeg_curves, err] = calcRefpts0(surf, Nz, Iz, RPA, LPA, Czi, stepsizes);
    case 'antitragus'
        [eeg_curves, err] = calcRefpts0(surf, Nz, Iz, RPA, LPA, Czi, stepsizes);
    otherwise
        [eeg_curves, err] = calcRefpts0(surf, Nz, Iz, RPA, LPA, Czi, stepsizes);
end

refpts.eeg_system.curves = eeg_curves;
refpts = set_eeg_active_pts(refpts);

refpts = calcRefptsCircumf(refpts);
