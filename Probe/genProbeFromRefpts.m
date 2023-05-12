function SD = genProbeFromRefpts(refpts, dt, nW, options)
optpos = refpts.pos;
ml = [];
if nargin==0
    return;
end
if ~exist('dt','var')
    dt = 30;
end
if ~exist('nW','var')
    nW = 2;
end
if ~exist('options','var')
    options = 'springs';
end
iOptExcl = [];
iOptSrcNext = 1;
iSrc = 1;
iDet = 0;
srcpos = zeros(size(optpos));
detpos = zeros(size(optpos));
dm     = distmatrix(optpos);
N      = size(optpos,1);
while 1
    % Find next source
    k = [];
    for jj = iOptSrcNext:N
        if ~ismember(jj, iOptExcl)
            k = jj;
            break;
        end
    end
    if isempty(k)
        break;
    end
    iOptSrcNext = k;
    
    % Add source
    srcpos(iSrc,:) = optpos(iOptSrcNext,:);
        
    % Find detectors
    k1 = find((dm(iOptSrcNext,:)>0) & (dm(iOptSrcNext,:)<dt));
    k2 = find((dm(:,iOptSrcNext)>0) & (dm(:,iOptSrcNext)<dt));
    k = [k1(:)',k2(:)'];
    k(ismember(k, iOptExcl)) = [];
    idxsNew = iDet+1:iDet+length(k);
        
    % Add detectors
    detpos(idxsNew,:) = optpos(k,:);
    
    % Add to list of excluded optode indices
    iOptExcl = unique([iOptExcl, iOptSrcNext, k]);

    % Add to measurement list
    n = size(ml,1);
    for ii = 1:length(idxsNew)
        ml(n+ii,:) = [iSrc, idxsNew(ii)];
    end

    iSrc = iSrc+1;
    iDet = iDet+length(idxsNew);
end
srcpos(iSrc:end,:) = [];
detpos(iDet+1:end,:) = [];


% Create a more complete set of channels between detectors and sources
for ii = 1:size(detpos)
    for jj = 1:size(srcpos)
        if dist3(detpos(ii,:), srcpos(jj,:)) < dt
            k = find(ml(:,1)==jj & ml(:,2)==ii);
            if isempty(k)
                ml = [ml; [jj, ii]];
            end
        end
    end
end
ml = sortrows(ml);
ml = [ml, zeros(size(ml,1),1), ones(size(ml,1),1)];

[srcpos, ml, dummypos1] = squeezeOptodes(srcpos, ml, 1);
[detpos, ml, dummypos2] = squeezeOptodes(detpos, ml, 2);

dummypos = [dummypos1; dummypos2];

% Create multiple wavelength meas list
ml0 = ml;
ml = zeros(nW*size(ml0,1),4);
w0 = 650;
Wstep = 100;
lambda = zeros(1,nW);
for ii = 1:nW
    iS = (ii-1)*size(ml0,1)+1;
    iE = iS+size(ml0,1)-1;
    ml(iS:iE, :)  =  [ml0(:,1:3), ii+zeros(size(ml0,1),1)];
    lambda(ii) = w0 + (ii-1)*Wstep;
end

% Create SD
SD = NirsClass().InitProbe(srcpos, detpos, ml, lambda, dummypos);
if optionExists(options, 'springs')
	SD = generateSpringRegistration(SD, refpts);
end
SD = movePts(SD, [50,80,-20], [1,1,1], [-80,110,-150]);

if optionExists(options, 'probe')
    profileFilename = [filesepStandard(pwd), 'probe.SD'];
    fprintf('Saving %s with ', profileFilename)
    save(profileFilename, '-mat', 'SD');
end




% --------------------------------------------------
function [optpos, ml, dummy] = squeezeOptodes(optpos, ml, idx)
% Get only src/det pairs
ml = ml((ml(:,4)==1), :);
mlNew = ml;

% Remove unused optodes
d = diff(ml(:,1))';
k = [];
for ii = 1:length(d)
    if d(ii)>1
        knew = ml(ii,idx)+1 : ml(ii+1,idx)-1;
        k = unique([k, knew]);
        mlNew(ii+1:end,1) = mlNew(ii+1:end,1) - (d(ii)-1);
    end
end
k = unique([k, max(ml(:,idx))+1:size(optpos,1)]);
dummy = optpos(k,:);
optpos(k,:) = [];
ml = mlNew;




% -----------------------------------------------
function SD = generateSprings(SD)
optpos = [SD.SrcPos; SD.DetPos; SD.DummyPos];
dm = distmatrix(optpos);
dt = 50;
sl = [];
kk = 1;
maxsprings = 3;
for ii = 1:size(dm,1)
    k = find(dm(ii,:)>0 & dm(ii,:)<dt);
    for jj = 1:length(k)
        if jj > maxsprings
            break
        end
        sl(kk,:) = [ii, k(jj), dm(ii,k(jj))];
        kk = kk+1;
    end
end
SD.SpringList = sl;




% -----------------------------------------------
function SD = generateAnchors(SD, refpts)
al = {};
optpos = [SD.SrcPos; SD.DetPos; SD.DummyPos];
r = rand(1, length(refpts.labels));
th = 88/100;
kk = 1;
for ii = 1:length(refpts.labels)
    if r(ii)>th
        [p, i] = nearest_point(optpos, refpts.pos(ii,:));
        if ~isempty(i)
            al(kk,:) = {i(1), refpts.labels{ii}};
            kk = kk+1;
        end
    end       
end
SD.AnchorList = al;




% -----------------------------------------------
function SD = generateSpringRegistration(SD, refpts)
SD = generateSprings(SD);
SD = generateAnchors(SD, refpts);




% -----------------------------------------------
function SD = movePts(SD, r, s, t)
if ~exist('r','var')
    r = [0,0,0];
end
if ~exist('s','var')
    s = [1,1,1];
end
if ~exist('t','var')
    t = [0,0,0];
end

alpha = deg2rad(r(1));
beta  = deg2rad(r(2));
theta = deg2rad(r(3));

A = [ ...
    1            0             0    0;
    0   cos(alpha)   -sin(alpha)    0;
    0   sin(alpha)    cos(alpha)    0;
    0            0             0    1;
    ];

B = [ ...
    cos(beta)    0     sin(beta)     0;
    0            1             0     0;
   -sin(beta)    0     cos(beta)     0;
    0            0             0     1;
    ];

C = [ ...
    cos(theta)   -sin(theta)   0     0;
    sin(theta)    cos(theta)   0     0;
    0            0             1     0;
    0            0             0     1;
    ];

D = [ ...
    1            0             0     t(1);
    0            1             0     t(2);
    0            0             1     t(3);
    0            0             0     1;
    ];

T = D*C*B*A;

SD.SrcPos = xform_apply(SD.SrcPos, T);
SD.DetPos = xform_apply(SD.DetPos, T);
SD.DummyPos = xform_apply(SD.DummyPos, T);


