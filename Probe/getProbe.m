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
    dirname = pwd;
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
if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1)='/';
end
dirname = fullpath(dirname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Load probe optodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe2d = initProbe();
probe3d = initProbe();

% 3D probe
% If digitized points exist and include optode positions then load optode positions 
% from digitized points. 
if ~digpts.isempty(digpts)
    probe3d = loadProbeFromDigpts(probe3d, digpts);
end

% 2D probe with measurement list
% Check if flat probe exists in default SD file
if exist([dirname, '/probe.SD'],'file')
    
    filedata = load([dirname, '/probe.SD'], '-mat');
    SD = filedata.SD;
    
elseif ~isempty(currElem) && ~currElem.IsEmpty()
    SD = currElem.GetSDG();
    foo = currElem.GetMeasList();
    SD.MeasList = foo.MeasList;
    save([dirname, 'probe.SD'],'-mat', 'SD');
    
% Check if flat probe exists in Homer processing output file
elseif exist([dirname, '/groupResults.mat'], 'file')
    
    filedata = load([dirname, '/groupResults.mat'], '-mat');
    SD = getSD(filedata.group);
    save([dirname, 'probe.SD'],'-mat', 'SD');
    
% Check if flat probe exists in fnirs data acquisition files
elseif existDataFiles()
    
    files = getDataFiles();
    filedata = load([dirname, files(1).folder, files(1).name], '-mat');
    SD = filedata.SD;
    save([dirname, 'probe.SD'],'-mat', 'SD');
    
else
    
    return;
    
end
probe2d = loadSD(probe2d, SD);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Check for consistency between 2D and 3D probes if both exist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TBD:


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Consolidate 2D and 3D probes into fine probe 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~probe3d.isempty(probe3d)
    probe = probe.copy(probe, probe3d);
    probe.ml = probe2d.ml;
else
    probe = probe.copy(probe, probe2d);
end

probe = preRegister(probe, headsurf, refpts);





% ----------------------------------------------------------------------
function b = existDataFiles(dirname)
if ~exist('dirname','var') || isempty(dirname)
    dirname = '.';
end
b = true;

files = dir([dirname, '/*.nirs']);
if ~isempty(files)    
    return;
end

dirs = dir([dirname, '/*']);
for ii = 1:length(dirs)
    if ~dirs(ii).isdir()
        continue
    end
    if strcmp(dirs(ii).name, '.')
        continue
    end
    if strcmp(dirs(ii).name, '..')
        continue
    end
    if existDataFiles(filesepStandard([dirname, '/', dirs(ii).name]))
        return
    end    
end
b = false;



% ----------------------------------------------------------------------
function files = getDataFiles(dirname)
if ~exist('dirname','var') || isempty(dirname)
    dirname = '.';
end
    
files = dir([dirname, '/*.nirs']);
for jj = 1:length(files)
    files(jj).folder = filesepStandard(dirname);
end

dirs = dir([dirname, '/*']);
for ii = 1:length(dirs)
    if ~dirs(ii).isdir()
        continue
    end
    if strcmp(dirs(ii).name, '.')
        continue
    end
    if strcmp(dirs(ii).name, '..')
        continue
    end
    fileNew = getDataFiles(filesepStandard([dirname, '/', dirs(ii).name]));
    files = [files; fileNew]; %#ok<AGROW>
end


