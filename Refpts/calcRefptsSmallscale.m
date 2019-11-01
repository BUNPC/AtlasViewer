function [refpts, labels, err] = calcRefptsSmallscale(refpts, head, labels)

%
% USAGE:
%
%    [refpts, labels] = calcRefptsSmallscale(refpts, head, labels, eeg_system)
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
%    refpts_10_20     - 29x3 matrix of coordinates of the 10-20 points.
%                       (Doesn't include initial reference points)
%
%    refpts_10_20_txt - Names each anatomical point in refpts_10_20 
%                       according to the 10-20 convention. 
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

err = true;

%%% Process args

% Arg 1

if ~isstruct(head) && ndims(head)==2
    surf = head;
    vertices = surf;
elseif ~isstruct(head) && ndims(head)==3
    fv = isosurface(head,.9);
    fv.vertices = [fv.vertices(:,2) fv.vertices(:,1) fv.vertices(:,3)];
    % [fv.vertices fv.faces] = reduceMesh(fv.vertices, fv.faces, .2);
    surf = fv;
    vertices = surf.vertices;
elseif isstruct(head) && isfield(head,'img')
    fv = isosurface(head.img,.9);
    fv.vertices = [fv.vertices(:,2) fv.vertices(:,1) fv.vertices(:,3)];
    % [fv.vertices fv.faces] = reduceMesh(fv.vertices, fv.faces, .2);
    surf = fv;    
    vertices = surf.vertices;
elseif isstruct(head) && isfield(head,'mesh')    
    surf = head.mesh;
    vertices = surf.vertices;
end


% Arg 2
if isstruct(refpts)
    pos    = refpts.pos;
    labels = refpts.labels;
else
    pos = refpts;
end
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
kcz = find(strcmpi(labels,'cz'));

% Error checking 
if isempty(knz)
    return;
end
if isempty(kiz)
    return;
end
if isempty(krpa)
    return;
end
if isempty(klpa)
    return;
end
if isempty(kcz)
    return;
end

Nz  = pos(knz,:);
Iz  = pos(kiz,:);
RPA  = pos(krpa,:);
LPA  = pos(klpa,:);
Czi = pos(kcz,:);

% Distance threshold for the curve_gen to determine 
% the surface points on the head which intersect with a plane
% dt=.5;
dt=.5;

% Step sizes as a percentage of curve length
switch(refpts.eeg_system.selected)
    case '10-10'
        stepsize1 = 10;
        stepsize2 = 25;
        %stepsize3 = 9.0910;
        stepsize3 = 8.3333;
    case '10-5'
        stepsize1 = 5;
        stepsize2 = 12.5;
        stepsize3 = 4.5455;
    case '10-2.5'
        stepsize1 = 2.5;
        stepsize2 = 6.25;
        stepsize3 = 2.2727;
    case '10-1'
        stepsize1 = 1;
        stepsize2 = 1.5625;
        stepsize3 = 0.9091;
    otherwise
        return;
end
n1 = uint32(100/stepsize1)-1;
n2 = uint32(100/stepsize2)-1;
n3 = uint32(100/stepsize3)-1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: How to get a more accurate location of Cz? Roughly speaking, Cz is the point 
% on the surface of the head that is equidistant from LPA and RPA, and from
% Nz and Iz, respectively.
% 
% The procedure used here to approximate this point is as follows:
%
% 1. Find the midpoint of LPA-Czi-RPA (Where Czi is the user's initial guess at Cz), call it Mp_LPACziRPA. 
%
% 2. Find the curve between Nz and Iz through the point Mp_LPACziRPA (in the code it's the 1st recalculation of Czi), 
%
% 3. Find the midpoint of the curve Nz-Mp_LPACziRPA-Iz. This second midpoint we take to be our Cz.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

% Find the curve from LPA to RPA through our initial guess, Czi
[curve_pts_LPACziRPA, len_LPACziRPA] = curve_gen(LPA, RPA, Czi, surf, dt);
fprintf('Initial LPA-RPA curve length: %1.1f\n', len_LPACziRPA);

display('Recalculating our guess for Cz along the curve LPA-RPA...');

% Recalculate Czi: Find the midpoint of curve from LPA to RPA 
% through our initial guess, Czi. The midpoint will be our new Czi
Czi = curve_walk(curve_pts_LPACziRPA, len_LPACziRPA/2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve and ref pts from Nz to Iz through the recalculated Czi. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[refpts_NzCziIz, labels_NzCziIz, curve_pts_NzCziIz, len_NzCziIz] = ...
    gen_curve_refpts(Nz, Iz, Czi, 'Nz', 'Iz', 'Czi', stepsize1, n1, surf, dt);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find Cz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Cz, len] = curve_walk(curve_pts_NzCziIz, 50*len_NzCziIz/100);
fprintf('Cz = (%1.1f, %1.1f, %1.1f) is %1.2f away from Nz\n', Cz(1), Cz(2), Cz(3), len);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve and ref pts from LPA to RPA through Cz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[refpts_LPACzRPA, labels_LPACzRPA, curve_pts_LPACzRPA, len_LPACzRPA] = ...
    gen_curve_refpts(LPA, RPA, Cz, 'LPA', 'RPA', 'Cz', stepsize3, n3, surf, dt, true);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Concentric curves around the head
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m =  uint32(10/stepsize1)+1;
%m =  1;
refpts_front2back = [];
labels_front2back = {};
for ii=1:m
    ps = refpts_NzCziIz(ii,:);
    pe = refpts_NzCziIz(end-(ii-1),:);
    ls = labels_NzCziIz{ii};
    le = labels_NzCziIz{end-(ii-1)};

    pm = refpts_LPACzRPA(ii+1,:);
    lm = labels_LPACzRPA{ii+1};
    [refpts1, labels1] = gen_curve_refpts(ps, pe, pm, ls, le, lm, stepsize1, n1, surf, dt, true);
    
    pm = refpts_LPACzRPA(end-ii,:);
    lm = labels_LPACzRPA{end-ii};
    [refpts2, labels2] = gen_curve_refpts(ps, pe, pm, ls, le, lm, stepsize1, n1, surf, dt, true);

    refpts_front2back = [refpts_front2back; refpts1; refpts2]; 
    labels_front2back = [labels_front2back; labels1; labels2]; 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Left-right curves over the top of head
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m =  uint32(10/stepsize1)+1;
s = length(m+1:n1-m+2);
refpts_side2side = [];
labels_side2side = {};
refpts_front2back_l = refpts1;
refpts_front2back_r = refpts2;
labels_front2back_l = labels1;
labels_front2back_r = labels2;
for ii=m+1:n1-m+2
    if ii==uint32(n1/2)+1
        continue;
    end
    
    if (ii-m)<=round(s/14) | (ii-m)>round(s-s/14)
        stepsize = stepsize2;
        n = n2;
    else
        stepsize = stepsize2/2;
        n = uint32(100/stepsize)-1;
    end
    pm = refpts_NzCziIz(ii,:);
    lm = labels_NzCziIz{ii};

    ps = refpts_front2back_l(ii,:);
    pe = refpts_front2back_r(ii,:);
    ls = labels_front2back_l{ii};
    le = labels_front2back_r{ii};
    [refpts1, labels1] = gen_curve_refpts(ps, pe, pm, ls, le, lm, stepsize, n, surf, dt, true);

    refpts_side2side = [refpts_side2side; refpts1]; 
    labels_side2side = [labels_side2side; labels1]; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assemble all the points and labels together into one array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos = ...
[...
    refpts_NzCziIz; ...
    refpts_LPACzRPA; ...
    refpts_front2back; ...
    refpts_side2side; ...
];

labels = ...
[...
    labels_NzCziIz; ...
    labels_LPACzRPA; ...
    labels_front2back; ...
    labels_side2side; ...
];

% Throw out redundant ref pts
[pos, labels] = removeRedundantRefpts(pos, labels, labels_NzCziIz);
[pos, labels] = removeRedundantRefpts(pos, labels, labels_LPACzRPA);
[pos, labels] = removeRedundantRefpts(pos, labels, {'Czi'}, true);

% Relabel impossibly long labels
hwait = waitbar(0,'Please wait...');
pcount=1;
N=length(labels);
for ii=1:N
    if length(labels{ii})>5
        % labels{ii} = sprintf('p%d',pcount);
        labels{ii} = '.';
    end
    pcount=pcount+1;
    if mod(ii,20)==0
        waitbar(ii/N,hwait,sprintf('Relabeling label %d of %d...', ii, N));
    end
end
close(hwait);


% Make sure output type matches input type
if isstruct(refpts)
    refpts.pos = pos;
    refpts.labels = labels;
    if length(labels)>=50 & length(labels)<=100
        refpts.size = 9;
    elseif length(labels)>100
        refpts.size = 8;
    end
else
    refpts = pos;
end

err = false;



% -------------------------------------------------------------------------------------
function [refpts, labels, curve_pts, len] = gen_curve_refpts(ps, pe, pm, ls, le, lm, stepsize, n, surf, dt, symmetric)

refpts = [];
labels = {};

if ~exist('symmetric','var') | isempty(symmetric)
    symmetric=false;
end

[curve_pts, len] = curve_gen(ps, pe, pm, surf, dt);
for ii=1:n
    labels{ii,1} = sprintf('%s%s%s%d', ls, lm, le, ii);
end
labels{uint8(n/2),1} = lm;
labels = [ls; labels; le];

if symmetric
    [foo, im] = nearest_point(curve_pts, pm);
    refpts1 = calcRefptsAlongCurve(curve_pts(1:im,:), 0, labels, stepsize*2, sprintf('%s-%s', ls, lm));
    refpts2 = calcRefptsAlongCurve(curve_pts(im+1:end,:), 0, labels, stepsize*2, sprintf('%s-%s', le, lm));
    refpts = [refpts1; refpts2];
else
    refpts = calcRefptsAlongCurve(curve_pts, len, labels, stepsize, sprintf('%s-%s-%s', ls, lm, le));
end

refpts(uint8(n/2),:) = pm;
refpts = [ps; refpts(1:end-1,:); pe];




% -------------------------------------------------------------------------------------
function [pos, labels] = removeRedundantRefpts(pos, labels, labelsRedundant, removeall)

if ~exist('removeall','var')
    removeall = false;
end

for  ii=1:length(labelsRedundant)
    lb = labelsRedundant{ii};
    k = find(strcmp(lb,labels));
    if removeall==true
        pos(k,:) = [];
        labels(k) = [];        
    end        
    if k>1
        pos(k(2:end),:) = [];
        labels(k(2:end)) = [];
    end
end

