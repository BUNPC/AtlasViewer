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
probe_SD        = loadFromSDFiles(dirname, probe_digpts, probe_data);

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
probe = checkRegistrationData(dirname, probe, headsurf);

% Generate measurement list mid points in 3D if #D optodes exist
probe = findMeasMidPts(probe);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Save new probe 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% probe.save(probe);



% -------------------------------------------
function probe = loadFromSDFiles(dirname, varargin)

% Arg 2: Extract all the probes from varargin agianst which the SD probes have to
% be compared for compatability
probe_other_srcs          = repmat(initProbe, length(varargin),1);
probe_other_srcs_status   = zeros(1, length(probe_other_srcs));
for n = 1:length(varargin)
    probe_other_srcs(n)        = varargin{n};
    probe_other_srcs_status(n) = probe_other_srcs(n).isempty(probe_other_srcs(n));
end

% Check if multiple SD files are available. If more than one probe is
% availale then ask user to which one to import otherwise import the probe
files = dir('./*.SD');
probe = initProbe();
if length(files) == 1
    filedata = load([dirname, files(1).name], '-mat');
    probe = loadSD(probe, filedata.SD);
    probe.filename_to_save = files(1).name(1:end-3);
elseif length(files) > 1
    [filename, pathname] = uigetfile('*.SD','Please select the SD file you want to load');
    if filename==0
        return;
    end
    filedata = load([pathname filename], '-mat');
    probe = loadSD(probe, filedata.SD);
    probe.filename_to_save = filename(1:end-3);
end

% % Load probe into the array output parameter from the default SD files
% % We make sure this file is firast in the array
% files = [dir(['./*.SD']); dir(['./*.sd'])];
% probe = repmat(initProbe, length(files),1);
% jj = 0;
% if ispathvalid([dirname, 'probe.SD'],'file')
%     filedata = load([dirname, 'probe.SD'], '-mat');
%     jj = jj+1;
%     probeDefault = initProbe();
%     probe = [loadSD(probeDefault, filedata.SD); probe];    
% end
% 
% % Load all the other probes from the rest of the SD files (non-default
% % ones). Then decide whether ask the user to choose among multiple SD
% % files.
% askuserflag = false;
% idxLst = [];
% for ii = 1:length(files)
%     
%     if strcmp(files(ii).name, 'probe.SD')
%         idxLst = [idxLst, ii+jj]; %#ok<*AGROW>
%         continue;
%     end
%     
%     filedata = load([dirname, files(ii).name], '-mat');
%     probe(ii+jj) = loadSD(probe(ii+jj), filedata.SD);
%     
%     % Check if there's a reason to ask user to choose an SD file.
%     % In order for the code to decide to ask the user to choose
%     % among mutiple SD files 3 conditions must be met:
%     %
%     %   a) All of the probes listed in varargin must be empty
%     %   c) Default SD file 'probe.SD' must not exist
%     %   d) Multiple SD files must exist at least one of which is
%     %      dissimilar to/incompatible with any one of the others.
%     %
%     for kk = 1:length(probe)
%         if ~compatibleProbes(probe(ii+jj), probe(kk))
%             if jj==0
%                 if all(probe_other_srcs_status)
%                     askuserflag = true;
%                 end
%             end
%         end
%     end
%     
% end
% probe(idxLst(2:end)) = [];
% 
% 
% % If askuserflag is set prompt user to select from mutiple incompatible
% % SD files
% if askuserflag
%     probe = initProbe();
%     [filename, pathname] = uigetfile('*.SD','Please select the SD file you want to load');
%     if filename==0
%         return;
%     end
%     filedata = load([pathname, '/', filename], '-mat');
%     probe = loadSD(probe, filedata.SD);
% end




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



