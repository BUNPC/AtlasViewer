function [subjDirs, groupDir, group] = findSubjDirs(dirname0)

if ~exist('dirname0','var') || ~exist(dirname0, 'dir')
    dirname0 = pwd;
end
if dirname0(end)~='/' && dirname0(end)~='\'
    dirname0(end+1) = '/';
end

% Look first in the parent folder for groupResults.mat. If the the current 
% folder also has groupResults.mat, the parent folder's grouypResults
% take precedence.
dirname = fileparts(dirname0(1:end-1));
[subjDirs, groupDir, group] = searchDir(dirname);
if isempty(groupDir)
    % try the parent folder one level up. To do that get fileparts of 
    % dirname without the '/' at the end and fileparts will give 
    % back the parent folder. 
    [subjDirs, groupDir, group] = searchDir(dirname0);
end



% -------------------------------------------------------------
function [subjDirs, groupDir, group] = searchDir(dirname)

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
    foos = mydir({'*.nirs','*.sd','*.SD','atlasViewer.mat'});
    if length(foos) > 0
        subjDirs(kk) = subjDirs0(ii);
        kk=kk+1;
    end
    cd('../');
end

% Check to make sure the group results are associated with
% this folder (dirname)
% for ii=1:length(group.subjs)
%     flag = false;
%     for jj=1:length(subjDirs)
%         if strcmpi(group.subjs(ii).name, subjDirs(jj).name)
%             flag = true;
%         end
%     end
%     if flag == false
%         group = [];
%     end
% end

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
        new = dir(strs{ii});
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

