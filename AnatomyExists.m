function b = AnatomyExists(dirname)

b = false;

if ~exist('dirname','var')
    dirname = pwd;
end
if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1)='/';
end
dirnameAnat = [dirname, 'anatomical/'];

if exist([dirnameAnat, 'headsurf.mesh'],'file')
    b=true;
end
if exist([dirnameAnat, 'headvol.vox'],'file')
    b=true;
end


