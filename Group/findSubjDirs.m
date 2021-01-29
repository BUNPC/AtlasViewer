function [subjDirs, groupDir, group] = findSubjDirs(dirname0)

if ~exist('dirname0','var') || ~exist(dirname0, 'dir')
    dirname0 = pwd;
end
dirname0 = filesepStandard(dirname0);

% Look first in the current folder for groupResults.mat.
[subjDirs, groupDir, group] = searchDir(dirname0);
if isempty(groupDir)
    % Now try looking in the parent folder
    dirname = fileparts(dirname0(1:end-1));
    [subjDirs, groupDir, group] = searchDir(dirname);
end



% -------------------------------------------------------------
function [subjDirs, groupDir, group] = searchDir(dirname)
global supportedFormats

subjDirs = mydir('');
groupDir = '';

currdir = pwd;

group = loadGroupNirsDataFile(dirname);
if isempty(group)
    return;
end

cd(dirname);
groupDir = pwd;

subjDirs0 = mydir();
kk=1;
for ii=1:length(subjDirs0)
    if ~subjDirs0(ii).isdir
       continue;
    end
    if strcmp(subjDirs0(ii).name,'.')
       continue;
    end
    if strcmp(subjDirs0(ii).name,'..')   
       continue;
    end
    if strcmp(subjDirs0(ii).name,'hide')   
       continue;
    end
    if kk>length(group.subjs)
       break;
    end
    
    cd(subjDirs0(ii).name);
    foos = mydir([supportedFormats(:,1); {'groupResults.mat'}]);
    if ~isempty(foos)
        subjDirs(kk) = subjDirs0(ii);
        kk=kk+1;
    end
    cd('../');
end

cd(currdir);



% -------------------------------------------------------------
function files = mydir(strs)

files = dir('');
files0 = {};
if ~exist('strs','var')
    files = dir();
else
    kk=1;
    for ii=1:length(strs) 
        filenames = strs{ii};
        if strs{ii}(1)=='.'
            filenames = ['*', strs{ii}];
        end
        new = dir(filenames);
        for jj=1:length(new)
            files0{kk} = new(jj).name;
            kk=kk+1;
        end
    end
    
    % On windows uppercase and lowercase isn't distinuished leading to
    % duplicate files. We discard them here with the call to unique
    files0 = unique(files0);
    
    for ii=1:length(files0)
        files(ii) = dir(files0{ii});
    end
end

