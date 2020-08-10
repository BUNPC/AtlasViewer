function dirname = getSubjDir(arg)

if ~exist('arg','var') || isempty(arg)
    arg = {''};
end

dirname = -1;
if length(arg) > 1
    dirname = arg{1};
else
    
    % Rules fr determining if current folder is a subject folder    
    % Check for presence of atlasviewer files 
    % in the current folder
    
    % 1. Check for presense of ./anatomical/headsurf.mesh
    dirname = [];
    if exist([pwd, '/anatomical'], 'dir')
        files = dir([pwd, '/anatomical/headsurf.mesh']);
        if ~isempty(files)
            dirname = pwd;
        end
    end
    
    % 2. Check for presense of ./anatomical/headsurf.mesh
    if exist([pwd, '/fw'], 'dir')
        files = dir([pwd, '/fw/fw_all.*']);
        if ~isempty(files)
            dirname = pwd;
        end
        files = dir([pwd, '/fw/headvol.vox']);
        if ~isempty(files)
            dirname = pwd;
        end
    end
    
    % 3. Check for presense of digpts.txt
    if exist([pwd, '/digpts.txt'], 'file')
        dirname = pwd;
    end
    
    % 4. Check for presense of atlasViewer.mat
    if exist([pwd, '/atlasViewer.mat'], 'file')
        dirname = pwd;
    end
    
    % 5. Check for presense of groupResults.mat
    if exist([pwd, '/groupResults.mat'], 'file')
        dirname = pwd;
    end
        
    % 6. Check for presense of SD or .nirs files
    files = dir([pwd, '/*.SD']);
    if ~isempty(files)
        dirname = pwd;
    end
    
    % 7. Check for presense of SD or .nirs files
    files = dir([pwd, '/*.nirs']);
    if ~isempty(files)
        dirname = pwd;
    end
    
    % After checking all the above for insications of subject folder
    % see if dirname is etill empty. If it is ask user for subject dir. 
    if isempty(dirname)
        pause(.1);
        dirname = uigetdir(pwd, 'Please select subject folder');
        if dirname==0
            dirname = pwd;
        end
    end
    
end

if isempty(dirname) | dirname==0
    return;
end

cd(dirname);

dirname(dirname=='\') = '/';

if dirname(end) ~= '/'
    dirname(end+1) = '/';
end



