function group = loadGroupNirsDataFile(dirname)

group = [];
if ~exist('dirname','var') || ~exist(dirname, 'dir')
    dirname = pwd;
end
if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1) = '/';
end

% If groupResult.mat does not exist in the folder dirname then it's not a
% group folder. 
if ~exist([dirname, 'groupResults.mat'],'file')
    return;
end

% Error checks: If groupResults exists but is corrupt then it's not a
% group folder.
warning('off', 'MATLAB:load:cannotInstantiateLoadedVariable');
warning('off', 'MATLAB:load:classNotFound');
nirsdata = load([dirname, 'groupResults.mat']);
warning('on', 'MATLAB:load:cannotInstantiateLoadedVariable');
warning('on', 'MATLAB:load:classNotFound');

if ~isstruct(nirsdata)
    return;
end
if ~isfield(nirsdata, 'group')
    return;
end
if ~isstruct(nirsdata.group) && ~isobject(nirsdata.group)
    return;
end
if ~isfield(nirsdata.group, 'procResult')
    return;
end
if ~isfield(nirsdata.group, 'procInput')
    return;
end
if ~isfield(nirsdata, 'group')
    return;
end
group = nirsdata.group;
