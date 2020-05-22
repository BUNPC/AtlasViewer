function [probe,s,d] = getProbe(probe, dirname, headsurf, digpts, refpts)

s = [];
d = [];
if iscell(dirname)
    for ii=1:length(dirname)
        probe = getProbe(probe, dirname{ii}, headsurf);
        if ~probe.isempty(probe)
            return;
        end
    end
    return;
end

if isempty(dirname)
    return;
end

filename = '';
ext = '';
if exist(dirname,'file')==2
    [dirname,filename,ext] = fileparts(dirname);
    filename = [filename,ext];    
elseif exist(dirname,'dir')==7 && exist([dirname, '/probe.SD'],'file')
    dirname = fullpath(dirname);
    filename = 'probe.SD';
    ext = '.SD';
elseif exist(dirname,'dir')==7
    if dirname(end)~='/' && dirname(end)~='\'
        dirname(end+1)='/';
    end
else
    return;
end


if nargin<3
    headsurf = initHeadsurf();
    digpts = initDigpts();
    refpts = initRefpts();
end

%%%%% Load probe from various file formats
switch lower(ext)
    case '.mat'

        return;
        
    case '.txt'

        probe.optpos   = load([dirname, filename], '-ascii');
        probe.nopt     = size(probe.optpos,1);
        probe.noptorig = size(probe.optpos,1);

    case {'.sd','.nirs'}

        filedata = load([dirname filesep filename], '-mat');
        probe = loadSD(probe,filedata.SD);

    % In this case dirname is actually a directory 
    % we are in that case looking for default subject files
    case ''
        
        % TDB: Implement loading default probe file here. I think probe.txt
        % is a step in that direction if not the whole thing, but not completely 
        % sure ????
        
        % First try to get the probe from the digitized points if they
        % exist
        if ~digpts.isempty(digpts)
            probe.srcpos   = digpts.srcpos;
            probe.nsrc     = size(digpts.srcpos,1);
            probe.detpos   = digpts.detpos;
            probe.ndet     = size(digpts.detpos,1);
            probe.optpos   = [probe.srcpos; probe.detpos];
            probe.noptorig = size(probe.optpos,1);
            probe.srcmap   = digpts.srcmap;
            probe.detmap   = digpts.detmap;
            probe.center   = digpts.center;
            probe.orientation = digpts.orientation;
        elseif ~isempty(digpts.digpts)
            probe.srcpos   = digpts.digpts(1).srcpos;
            probe.nsrc     = size(digpts.digpts(1).srcpos,1);
            probe.detpos   = digpts.digpts(1).detpos;
            probe.ndet     = size(digpts.digpts(1).detpos,1);
            probe.optpos   = [probe.srcpos; probe.detpos];
            probe.noptorig = size(probe.optpos,1);
            probe.srcmap   = digpts.digpts(1).srcmap;
            probe.detmap   = digpts.digpts(1).detmap;
            probe.center   = digpts.digpts(1).center;
            probe.orientation = digpts.digpts(1).orientation;
            for ii=1:length(digpts.digpts)
                [rp_atlas, rp_subj] = findCorrespondingRefpts(refpts, digpts.digpts(ii));
                T_2atlas = gen_xform_from_pts(rp_subj, rp_atlas);
                
                s(:,:,ii) = xform_apply(digpts.digpts(ii).srcpos, T_2atlas);
                d(:,:,ii) = xform_apply(digpts.digpts(ii).detpos, T_2atlas);                

                % Get running average positions 
                probe.srcpos = (s(:,:,ii) + (ii-1) * probe.srcpos) / ii;
                probe.detpos = (d(:,:,ii) + (ii-1) * probe.detpos) / ii;

                probe.optpos   = [probe.srcpos; probe.detpos];
            end
        elseif exist([dirname, 'probe.txt'])
            probe.optpos   = load([dirname, 'probe.txt'], '-ascii');            
            probe.nopt     = size(probe.optpos,1);
            probe.noptorig = size(probe.optpos,1);
        else
            return;
        end
        
    otherwise

        menu('Error: Unknown file format for digitized points file.','ok');
        return;
       
end


% Once probe data is loaded check if src/det data is there 
if isempty(probe.optpos)

    % 
    if ~isempty(digpts.digpts)
        dirname = digpts.digpts(1).pathname;
    end
    
    % Search if there are any related SD files 
    files = dir([dirname, '*.sd']);
    for ii=1:length(files)
        filedata = load([dirname, files(ii).name],'-mat');
        if ~isfield(filedata, 'SD')
            continue;
        end
        SD = filedata.SD;
        if ~isfield(SD, 'SrcPos')
            continue;
        end        
        if ~isfield(SD, 'DetPos')
            continue;
        end
        nOpt = size([SD.SrcPos; SD.DetPos], 1);        
        if probe.nopt ~= nOpt
            continue;
        end
        
        probe.srcpos = SD.SrcPos(:,1:2);
        probe.detpos = SD.DetPos(:,1:2);        
        probe.nsrc = size(probe.srcpos,1);
        probe.ndet = size(probe.detpos,1);
        probe.srcmap = [1:probe.nsrc];
        probe.detmap = [1:probe.ndet];
        break;
    end
   
elseif ~isempty(probe.optpos)
        
    % Check if the probe is already registered. One indicator is if
    % the probe isn't flat. Another is if all optodes are on or close to the head surface.
    [foo1, foo2, d] = nearest_point(headsurf.mesh.vertices, probe.optpos);
    if ~isempty(d) && (mean(d)>5 | std(d)>1)
        % We are loading a flat probe that needs to be anchored to the
        % head. Bring flat probe to some point on head surface to make the
        % imported probe at least somewhat visible. To do this find
        % a reference point on the head surface (e.g. Cz) to anchor (ap)
        % the center of the probe to and translate the probe to that
        % anchor point.
        k = find(strcmpi(refpts.labels,'Cz'));
        if isempty(k)
            ap = refpts.pos(1,:);
        else
            ap = refpts.pos(k,:);
        end
        c = findcenter(probe.optpos);
        tx = ap(1)-c(1);
        ty = ap(2)-c(2);
        tz = ap(3)-c(3);
        T = [1 0 0 tx; 0 1 0 ty; 0 0 1 tz; 0 0 0 1];
        probe.optpos = xform_apply(probe.optpos, T);
    end
    digpts = disableDigpts(digpts);
    
    probe.center = headsurf.center;
    probe.orientation = headsurf.orientation;
    
    if isempty(probe.srcpos) & isempty(probe.detpos)
        probe.srcpos = probe.optpos;
        probe.nsrc = size(probe.srcpos,1);
        probe.srcmap = [1:probe.nsrc];
    end
    
elseif probeDigptsRelated(probe,digpts)
    
    % We have digitized some or all source and detector optodes.
    % These digitized points now serve as anchors for the
    % corresponding sources and detectors.
    % NOTE that we are not using digpts directly as in this case
    % digpts should be represented in atlasViewer.probe
    
    nSrcDig = size(digpts.srcpos,1);
    nSrc = probe.nsrc;
    nDetDig = size(digpts.detpos,1);
    nDet = probe.noptorig - probe.nsrc;
    
    for iS = 1:nSrcDig
        probe.al{iS,1} = digpts.srcmap(iS);
        probe.al{iS,2} = digpts.srcpos(iS,:);
    end
    for iD = 1:nDetDig
        probe.al{nSrcDig+iD,1} = nSrc+digpts.detmap(iD);
        probe.al{nSrcDig+iD,2} = digpts.detpos(iD,:);
    end
    probe.center = digpts.center;
    probe.orientation = digpts.orientation;
    
elseif ~isempty(probe.optpos_reg)
    
    if isempty(probe.srcpos) & isempty(probe.detpos)
        probe.srcpos = probe.optpos_reg;
        probe.nsrc = size(probe.srcpos,1);
        probe.srcmap = [1:probe.nsrc];
    end
    
end


% Get measurement list. However the measurement list is only
% valid if srcmap and detmap are 1:nsrc and 1:ndet respectively.
probe = loadMeasdList(probe, dirname);
if isempty(probe.ml)
    for ii=1:length(digpts.digpts)        
        probe = loadMeasdList(probe, digpts.digpts(ii).pathname);
        if isempty(probe.ml)
            break;
        end
    end    
end


% Check if probe anchor points exist in refpts
if ~refpts.isempty(refpts) && iscell(probe.al)
    nanchor = size(probe.al,1);
    for ii = 1:nanchor
        if ~ischar(probe.al{ii,2})
            continue;
        end
        if sum(strcmpi(refpts.labels, probe.al{ii,2}))==0
            if ~isnumber(probe.al{ii,2})
	            menu('The selected probe uses anchors points not included in the current anatomy.','Ok');
	            return;
            end
        end
    end
else
    probe.al = {};
end

if ~probe.isempty(probe)
    probe.pathname = [dirname, filename];
end




% -----------------------------------------
function b = isnumber(str)
b = ~isempty(str2num(str));



% -----------------------------------------
function msg = warningMsgs(filenm, probe, SD)

msg = '';
n1 = size(SD.SrcPos, 1);
n2 = size(SD.DetPos, 1);
m1 = probe.nsrc;
m2 = probe.ndet;

msg1 = sprintf('Warning: The number of optodes in digpts.txt (srcs: %d, dets: %d)\n', m1, m2);
msg2 = sprintf('does not equal the number in the SD file %s (srcs: %d, dets: %d). ', filenm, n1, n2);

msg = [msg1, msg2];



% -----------------------------------------
function probe = loadMeasdList(probe, dirname)

if probe.noptorig<=0
    return;
end
if ~isempty(probe.ml)
    return;
end

if ~isempty(1:probe.nsrc) & ~isempty(probe.srcmap)
    if ~all((1:probe.nsrc)==probe.srcmap)
        return;
    end
end
if ~isempty(1:probe.ndet) & ~isempty(probe.detmap)
    if ~all((1:probe.ndet)==probe.detmap)
        return;
    end
end
foos1 = dir([dirname '*.nirs']);
foos2 = dir([dirname '*.SD']);
foos3 = dir([dirname '*.sd']);

files = [foos1; foos2; foos3];

for ii=1:length(files)
    s = load([dirname, files(ii).name],'-mat');
    if size(s.SD.SrcPos,1)==probe.nsrc & size(s.SD.DetPos,1)==probe.ndet
        SD = s.SD;
        break;
    end
end
if ~exist('SD','var')
    return;
end
if isempty(SD.MeasList)
    return;
end

smax = max(SD.MeasList(:,1));
dmax = max(SD.MeasList(:,2));
if smax>probe.nsrc | dmax>probe.ndet
    msg1 = sprintf('Warning: Measurement list indices in the SD file %s exceed\n', files(1).name);
    msg2 = sprintf('the number of optodes. Will load only valid channels.');
    menu([msg1, msg2], 'OK');
    drawnow;
    ks = find(SD.MeasList(:,1) > probe.nsrc);
    kd = find(SD.MeasList(:,2) > probe.ndet);
    SD.MeasList([ks,kd],:) = [];
end

if ~isempty(SD.MeasList)
    k=[];
    if size(SD.MeasList,2)==4
        k = SD.MeasList(:,4)==1;
    elseif size(SD.MeasList,2)==2
        k = 1:size(SD.MeasList,1);
    end
    probe.ml = SD.MeasList(k,:);
end

