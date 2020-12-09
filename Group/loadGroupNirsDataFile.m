function group = loadGroupNirsDataFile(dirname)

currdir = pwd;
cd(dirname);

group = [];
if ~exist('dirname','var') || ~exist(dirname, 'dir')
    dirname = pwd;
end
dirname = filesepStandard(dirname);


% If groupResult.mat does not exist in the folder dirname then it's not a
% group folder. 
if ~exist([dirname, 'groupResults.mat'],'file')
    return;
end

% Create DataTreeClass object with an alternative constructor call, that is, 
% with options 'noloadconfig' and 'oneformat': 
% 
% 'noloadconfig' -  means do not prompt user to load processing stream function 
% calls from a % config file if the function calls in groupResults do not load. 
% AV might not % have user function definitions because they are not needed currently. 
% AV currently ONLY needs the groupResults output but not the corresponding function 
% call chain of input that goes with it. 
%
% 'oneformat': means do not prompt user if .nirs files are found, to
% convert them to .snirf. If .snirf files do not exist then assume there is
% no data set. 
dataTree = DataTreeClass({},'snirf','','noloadconfig:oneformat');

% Error checks: If groupResults exists but is corrupt then it's not a
% group folder.
if ~isa(dataTree, 'DataTreeClass')
    return;
end
if isempty(dataTree)
    return;
end
if isempty(dataTree.groups)
    return;
end
group = dataTree.groups(1);

cd(currdir)


