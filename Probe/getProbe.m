function probe = getProbe(probe, dirname, digpts, headsurf, refpts, dataTree)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Parse arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Arg 1
if ~exist('probe','var') || isempty(probe)
    probe = initProbe();
end

% Arg 2
if ~exist('dirname','var') || isempty(dirname)
    dirname = pwd;
end

% Arg 3
if ~exist('digpts','var') || isempty(digpts)
    digpts = initDigpts();
end

% Arg 4
if ~exist('headsurf','var')
    headsurf = initHeadsurf();
end

% Arg 5
if ~exist('refpts','var')
    refpts = initRefpts();
end

% Arg 6
if ~exist('dataTree','var')
    dataTree = [];
end

% Modify arguments
dirname = filesepStandard(dirname,'full');
probe.pathname = dirname;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Load probe data from the various possible sources
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe_data      = loadFromData(dirname, dataTree);
probe_digpts    = loadProbeFromDigpts(digpts);
probe_SD        = loadFromSDFiles(dirname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Copy all probe data loaded from different source which is not
% in conflict (NOTE: conflicts are checked by the probe struct copy()
% function) into the output parameter. The process of copying probe data to
% the probe output structure follows a hierarchy that looks
% like this:
%
%    a) If digitized points exists load probe data from it ONLY if it is
%       not in conflict with a) registered probe file.
%    b) If data exists, load probe data from it ONLY if it is
%       not in conflict with a) registered and b) digitized probes.
%    c) If SD files exist load probe data from it ONLY if it is
%       not in conflict with probe data loaded from a) registered probe file,
%       b) digitized points and c) data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get measurement list from data if data exists
if ~probe_digpts.isempty(probe_digpts)
    
    % Get digitized points if they exist
    probe = probe.copy(probe, probe_digpts);
    
    % We got our initial probe from dig points
    probe = probe.copyMeasList(probe, probe_data);

    % Get registration data from SD files
    for ii = 1:length(probe_SD)
        if ~probe_SD(ii).isempty(probe_SD(ii))
            probe = probe.copyMeasList(probe, probe_SD(ii));
            probe = probe.copyOptodes(probe, probe_SD(ii));
        end
    end
else
    probe = probe.copy(probe, probe_data);
    for ii = 1:length(probe_SD)
        if ~probe_SD(ii).isempty(probe_SD(ii))
            probe = probe.copy(probe, probe_SD(ii));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Preregister
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe = preRegister(probe, headsurf, refpts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Check if registration data exists only if data from SD data was loaded.
% If it was but probe is neither registered to head nor has registration
% data, then offer to add it manually
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe = checkRegistrationData(dirname, probe, headsurf, refpts);

% Generate measurement list mid points in 3D if #D optodes exist
probe = checkMeasList(probe);



% -------------------------------------------
function probe = loadFromSDFiles(dirname)
probe = initProbe();

% Check if multiple SD files are available. If more than one probe is
% availale then ask user to which one to import otherwise import the probe
files1 = dir('./*.SD');
files2 = dir('./*.nirs');
files3 = dir('./*.snirf');
files = [files1; files2; files3];

% Check how many unique probes there are and throw away any redundant ones
files = findUniqueProbeFiles(files);

if length(files) == 1
    [~, ~, ext] = fileparts(files(1).name);
    if strcmpi(ext, '.SD')
        filedata = load([dirname, files(1).name], '-mat');
        probe = loadSD(probe, filedata.SD);
    elseif strcmpi(ext, '.snirf')
        s = SnirfClass([dirname, files(1).name]);
        n = NirsClass(s);
        probe = convertSD2probe(n.SD);
    end
elseif length(files) > 1
    [filename, pathname] = uigetfile({'*.SD; *.snirf'},'Please select the probe file you want to load');
    if filename==0
        return;
    end
    [~, ~, ext] = fileparts(filename);
    if strcmpi(ext, '.SD')
        filedata = load([pathname filename], '-mat');
        probe = loadSD(probe, filedata.SD);
    elseif strcmpi(ext, '.snirf')
        s = SnirfClass([dirname, filename]);
        n = NirsClass(s);
        probe = convertSD2probe(n.SD);
    end
end



% -------------------------------------------
function probe = loadFromData(dirname, dataTree)
probe = initProbe();
SD = [];

% Check if probe in data tree
if ~isempty(dataTree) && ~dataTree.IsEmpty()
    SD = extractSDFromDataTree(dataTree);
    % Check if probe exists in old-style Homer processing files
elseif exist([dirname, 'groupResults.mat'], 'file')
    filedata = load([dirname, 'groupResults.mat'], '-mat');
    SD = getSD(filedata.group);
    
    % Check if probe exists in old-style acquisition files
elseif existDotNirsFiles(dirname)
    files = getDotNirsFiles(dirname);
    filedata = load([files(1).folder, files(1).name], '-mat');
    SD = sd_data_Copy(SD, filedata.SD);
    
end
if isempty(SD)
    return
end
probe = loadSD(probe, SD);



% ----------------------------------------------------------------------
function b = existDotNirsFiles(dirname, depth)
b = true;
if ~exist('depth','var')
    depth = 0;
end
depth = depth+1;
if depth>2
    b = false;
    return;
end

files = dir([dirname, '*.nirs']);
if ~isempty(files)
    return;
end

dirs = dir([dirname, '*']);
for ii = 1:length(dirs)
    if ~dirs(ii).isdir
        continue
    end
    if strcmp(dirs(ii).name, '.')
        continue
    end
    if strcmp(dirs(ii).name, '..')
        continue
    end
    if strcmp(dirs(ii).name, '.git')
        continue
    end
    if strcmp(dirs(ii).name, '.svn')
        continue
    end
    if existDotNirsFiles(filesepStandard([dirname, dirs(ii).name]), depth)
        return
    end
end
b = false;



% ----------------------------------------------------------------------
function files = getDotNirsFiles(dirname)
if ~exist('dirname','var') || isempty(dirname)
    dirname = '.';
end

files = dir([dirname, '/*.nirs']);
if ~isempty(files)
    for jj = 1:length(files)
        files(jj).folder = dirname;
    end
    return;
end
dirs = dir([dirname, '*']);
for ii = 1:length(dirs)
    if ~dirs(ii).isdir
        continue
    end
    if strcmp(dirs(ii).name, '.')
        continue
    end
    if strcmp(dirs(ii).name, '..')
        continue
    end
    if strcmp(dirs(ii).name, '.git')
        continue
    end
    if strcmp(dirs(ii).name, '.svn')
        continue
    end
    fileNew = getDotNirsFiles(filesepStandard([dirname, dirs(ii).name]));
    files = [files; fileNew];
end


