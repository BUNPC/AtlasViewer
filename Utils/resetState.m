function resetState(dirname)

if ~exist('dirname','var')
    dirname = filesepStandard(pwd);
else
    dirname = filesepStandard(dirname);
end
delete([dirname, 'digpts*']);
deleteFiles(dirname);



% -----------------------------------------------------------
function deleteFiles(dirname)
global recursionDepth;

recursionDepth = recursionDepth+1;

if ~exist('dirname','var')
    dirname = filesepStandard(pwd);
else
    dirname = filesepStandard(dirname);
end

pause(.01);

if dirname(end)=='\' || dirname(end)=='/' 
    dirname1 = dirname(1:end-1);
else
    dirname1 = dirname;
end

[~, subdir] = fileparts(dirname1);
if recursionDepth > 3
    recursionDepth = recursionDepth-1; return;
end
if isempty(subdir)
    recursionDepth = recursionDepth-1; return;
end
if strcmp(subdir, '.')
    recursionDepth = recursionDepth-1; return;
end
if strcmp(subdir, '..')
    recursionDepth = recursionDepth-1; return;
end
if exist(dirname, 'dir') ~= 7
    recursionDepth = recursionDepth-1; return;
end

warning('off','all')

fprintf('%d. Resetting folder %s\n', recursionDepth, dirname);

try
    rmdir([dirname, 'fw'], 's');
catch
end

try
    rmdir([dirname, 'imagerecon'], 's');
catch
end

if exist([dirname, 'headsize.txt'], 'file')
    delete([dirname, 'digpts*']);
end

try
    delete([dirname, 'atlasViewer.mat']);
catch
end

try
    delete([dirname, 'probe.SD']);
catch
end


dirs = dir([dirname, '*']);

for ii = 1:length(dirs)
    deleteFiles([dirname, dirs(ii).name]);
end

warning('on','all')

recursionDepth = recursionDepth-1;
