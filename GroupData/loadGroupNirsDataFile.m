function group = loadGroupNirsDataFile(dirname)

currdir = pwd;
cd(dirname);

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
dataTree = DataTreeClass();
warning('on', 'MATLAB:load:cannotInstantiateLoadedVariable');
warning('on', 'MATLAB:load:classNotFound');

if ~isa(dataTree, 'DataTreeClass')
    return;
end
if isempty(dataTree)
    return;
end
group = dataTree.groups(1);

cd(currdir)
