function b = isAtlasDir(dirname)

b = false;

if ~exist('dirname','var') | ~exist(dirname,'dir')
    return;
end

% Add trailing file separator to dirname if there is none
dirname(dirname=='\') = '/';
if dirname(end) ~= '/' 
    dirname(end+1) = '/';
end

if exist([dirname, 'anatomical'],'dir')~=7
    return;
end

if exist([dirname, 'anatomical/headsurf.mesh'],'file')~=2
    return;
end

if exist([dirname, 'anatomical/headvol.vox'],'file')~=2 && ...
   exist([dirname, 'anatomical/headvol.vox.gz'],'file')~=2
    return;
end

if exist([dirname, 'anatomical/pialsurf.mesh'],'file')~=2
    return;
end

if exist([dirname, 'anatomical/refpts.txt'],'file')~=2
    return;
end

if exist([dirname, 'anatomical/refpts_labels.txt'],'file')~=2
    return;
end

b = true;

