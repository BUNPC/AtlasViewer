function dirname = selectAtlasDir(dirname)

if ~exist('dirname','var') | ~exist(dirname,'dir')
    dirname=pwd;
end
if exist(dirname,'file') & exist([dirname, '/anatomical'],'dir')
    if exist([dirname, '/anatomical/headsurf.mesh'],'file') | exist([dirname, '/anatomical/headvol.vox'],'file')
        return;
    end
end
    
while 1
    dirname = uigetdir(dirname,'Atlas directory not found. Please choose atlas directory');
    if dirname==0
        break;
    end
    if ~exist([dirname, '/anatomical/headvol.vox'],'file') && exist([dirname, '/anatomical/headvol.vox.gz'],'file')
        gunzip([dirname, '/anatomical/headvol.vox.gz']);
    end
    if exist(dirname,'dir') && exist([dirname, '/anatomical'],'dir') && ...
       exist([dirname, '/anatomical/headvol.vox'],'file')
        break
    else
        q = menu('Selected directory is not a valid atlas directory. Please select valid atlas directory or cancel to avoid selecting','Select','Cancel');
        if q==1
            continue;
        elseif q==2
            dirname = '';
            break;
        end
    end
end

if dirname==0
    dirname='';
end
