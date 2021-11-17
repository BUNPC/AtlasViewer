function b = isAtlasDir(dirname)
global logger

b = false;

logger.Write('isAtlasDir:   Checking  %s atlas folder\n', dirname);

if ~exist('dirname','var') || ~exist(dirname,'dir')
    return;
end

dirname = filesepStandard(dirname);

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

