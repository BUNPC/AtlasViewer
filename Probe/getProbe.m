function probe = getProbe(probe, dirname, digpts, group)

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
if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1)='/';
end
dirname = fullpath(dirname);

% Arg 3
if ~exist('digpts','var') || isempty(digpts)
    digpts = initDigpts();
end

% Arg 4
if ~exist('group','var')
    group = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Load probe optodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe2d = initProbe();
probe3d = initProbe();
currElem = LoadCurrElem(group);

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
elseif ~isempty(dir([dirname, '*.nirs']))
    
    files = dir([dirname, '*.nirs']);
    filedata = load([dirname, files(1).name], '-mat');
    SD = filedata.SD;
    save([dirname, 'probe.SD'],'-mat', 'SD');
    
else
    
    return;
    
end
probe2d = loadSD(probe2d, SD);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Check for consustency between 2D and 3D probes if both exist
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


