function dirname = getAppDir(isdeployed_override)

if ~exist('isdeployed_override','var')
    isdeployed_override = 'notdeployed';
end

if isdeployed() || strcmp(isdeployed_override, 'isdeployed')
    if ispc()
        dirname = 'c:/users/public/atlasviewer/';
    else
        currdir = pwd;
        cd ~/;
        dirnameHome = pwd;
        dirname = [dirnameHome, '/atlasviewer/'];
        cd(currdir);
    end
else
    dirname = fileparts(which('AtlasViewerGUI.m'));
end

dirname(dirname=='\') = '/';
if dirname(end) ~= '/'
    dirname(end+1) = '/';
end


