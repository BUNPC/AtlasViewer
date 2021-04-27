function probe = getProbe(probe, dirname, digpts, headsurf, refpts, currElem)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Parse arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Arg 1
if ~exist('probe','var') || isempty(probe)
    probe = initProbe();
    return
end

% Arg 2
if ~exist('dirname','var') || isempty(dirname)
    dirname = filesepStandard(pwd);
end

% Arg 3
if ~exist('digpts','var') || isempty(digpts)
    digpts = initDigpts();
end

% Arg 4
if ~exist('headsurf','var')
    headsurf = [];
end

% Arg 5
if ~exist('refpts','var')
    refpts = [];
end

% Arg 6
if ~exist('currElem','var')
    currElem = [];
end

% Modify arguments 
dirname = filesepStandard(dirname,'full');
probe.pathname = dirname;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Load probe data from the various possible sources
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe_reg       = loadProbeFormTextFile(dirname, headsurf);   % Probe that could already be registered
probe_data      = loadFromData(dirname, currElem);
probe_digpts    = loadProbeFromDigpts(digpts);
probe_SD        = loadFromSDFiles(dirname, probe_digpts, probe_data, probe_reg);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Copy all probe data loaded from different source which is not 
% in conflict (NOTE: conflicts are checked by the probe struct copy() 
% function) into the output parameter. The process of copying probe data to 
% the probe output structure follows a hierarchy that looks 
% like this:
%
%    a) If registered probe already exists in a file, load the data from it 
%    b) If digitized points exists load probe data from it ONLY if it is
%       not in conflict with a) registered probe file. 
%    c) If data exists, load probe data from it ONLY if it is
%       not in conflict with a) registered and b) digitized probes. 
%    d) If SD files exist load probe data from it ONLY if it is
%       not in conflict with probe data loaded from a) registered probe file, 
%       b) digitized points and c) data. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe = probe.copy(probe, probe_reg);
probe = probe.copy(probe, probe_digpts);
probe = probe.copy(probe, probe_data);
for ii = 1:length(probe_SD)
    probe = probe.copy(probe, probe_SD(ii));
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
probe = checkRegistrationData(dirname, probe, headsurf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Save new probe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe.save(probe);



% -------------------------------------------
function probe = loadFromSDFiles(dirname, varargin)

% Arg 2: Extract all the probes from varargin agianst which the SD probes have to
% be compared for compatability
probes_src          = repmat(initProbe, length(varargin),1);
probes_src_status   = zeros(length(probes_src), 1);
for n = 1:length(varargin)
    probes_src(n)           = varargin{n};
    probes_src_status(n)    = probes_src(n).isempty(probes_src(n));
end

% Load probe into the array output parameter from the default SD files
% We make sure this file is firast in the array
files = dir([dirname, '*.SD']);
probe = repmat(initProbe, length(files),1);
jj = 0;
if exist([dirname, 'probe.SD'],'file')
    filedata = load([dirname, 'probe.SD'], '-mat');
    jj = jj+1;
    probe(jj) = loadSD(probe(jj), filedata.SD);    
end
jj = jj+1;

% Load all the other probes from the rest of the SD files (non-default
% ones). Then decide whether ask the user to choose among multiple SD
% files.
askuserflag = false;
for ii = jj:length(files)
    if strcmp(files(ii).name, 'probe.SD')
        continue;
    end
    filedata = load([dirname, files(ii).name], '-mat');
    probe(ii) = loadSD(probe(ii), filedata.SD);
    
    % Check if there's a reason to ask user to choose an SD file.
    % In order for the code to decide to ask the user to choose 
    % among mutiple SD files 3 conditions must be met:
    %
    %   a) All of the probes listed in varargin must be empty
    %   c) Default SD file 'probe.SD' must not exist
    %   d) Multiple SD files must exist at least one of which is 
    %      dissimilar to/incompatible with any one of the others. 
    %
    for kk = 1:length(probe)
        if ~similarProbes(probe(ii), probe(kk))
            if jj==0
                if all(probes_src_status)
                    askuserflag = true;
                end
            end
        end
    end
end

% If askuserflag is set prompt user to select from mutiple incompatible 
% SD files
if askuserflag
    probe = initProbe();
    [filename, pathname] = uigetfile('*.SD','Please select the SD file you want to load');
    if filename==0
        return;
    end
    filedata = load([pathname, '/', filename], '-mat');
    probe = loadSD(probe, filedata.SD);
end



% -------------------------------------------
function probe = loadFromData(dirname, currElem)
probe = initProbe();
SD = [];

% Check if probe in data tree
if ~isempty(currElem) && ~currElem.IsEmpty()
    SD = extractSDFromDataTree(currElem);
    
% Check if probe exists in old-style Homer processing files
elseif exist([dirname, 'groupResults.mat'], 'file')    
    filedata = load([dirname, 'groupResults.mat'], '-mat');
    SD = getSD(filedata.group);

% Check if probe exists in old-style acquisition files
elseif existDotNirsFiles(dirname)
    files = getDotNirsFiles(dirname);
    filedata = load([files(1).folder, files(1).name], '-mat');
    SD = filedata.SD;
    
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
    files = [files; fileNew]; %#ok<AGROW>
end



