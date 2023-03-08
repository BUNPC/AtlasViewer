function b = isSubjDir(dirname)
b = false;

if nargin==0
    dirname = pwd;   
end
dirname = filesepStandard(dirname);    

if ~ispathvalid(dirname, 'dir')
    return;
end
    
% Rules for determining if current folder is a subject folder
% Check for presence of atlasviewer files
% in the current folder

% 1. Check for presense of ./anatomical/headsurf.mesh
if ispathvalid([dirname, 'anatomical'], 'dir')
    files = dir([dirname, 'anatomical/headsurf.mesh']);
    if ~isempty(files)
        b = true;
    end
end

% 2. Check for presense of ./anatomical/headsurf.mesh
if ispathvalid([dirname, 'fw'], 'dir')
    files = dir([dirname, 'fw/fw_all.*']);
    if ~isempty(files)
        b = true;
    end
    files = dir([dirname, 'fw/headvol.vox']);
    if ~isempty(files)
        b = true;
    end
end

% 3. Check for presense of digpts.txt
if ispathvalid([dirname, 'digpts.txt'], 'file')
    b = true;
end

% 4. Check for presense of atlasViewer.mat
if ispathvalid([dirname, 'atlasViewer.mat'], 'file')
    b = true;
end

% 5. Check for presense of groupResults.mat
if ispathvalid([dirname, 'groupResults.mat'], 'file')
    b = true;
end

% 5. Check for presense of groupResults.mat
if ispathvalid([dirname, 'homerOutput'], 'dir')
    b = true;
end

% 6. Check for presense of SD or .nirs files
files = dir([dirname, '*.SD']);
if ~isempty(files)
    b = true;
end

% 7. Check for presense of SD or .nirs files
files = dir([dirname, '*.nirs']);
if ~isempty(files)
    b = true;
end

% 8. Check for presense homer processed data
if ispathvalid([dirname, 'derivatives/homer'], 'dir')
    b = true;
end

