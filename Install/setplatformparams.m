function platform = setplatformparams()

% Set the home directoty on linux and mac to full path so it can be
% displayed in full at setup time.
if ismac() || islinux()
    currdir = pwd;
    cd ~/;
    dirnameHome = [pwd, '/'];
    cd(currdir);
else
    dirnameHome = 'c:/users/public/';
end


platform = struct(...
    'arch','', ...
    'mc_exe_name','tMCimg', ...
    'mc_exe_ext','', ...
    'exename',{{}}, ...
    'exenameDesktopPath','', ...
    'setup_exe',{{}}, ...
    'setup_script','', ...
    'dirnameApp', getAppDir_av('isdeployed'), ...
    'mcrpath','', ...
    'iso2meshmex',{{}}, ...
    'iso2meshbin','', ...
    'desktopPath',generateDesktopPath() ...
    );

exeext = getexeext();

fprintf('Final: exeext = %s\n', exeext);
platform.iso2meshmex{1} = ['cgalsimp2', exeext];
platform.iso2meshmex{2} = ['meshfix', exeext];
platform.iso2meshmex{3} = ['jmeshlib', exeext];
platform.iso2meshbin = findiso2meshbin();

if ismac()
    platform.arch = 'Darwin';
    platform.exename{1} = 'AtlasViewerGUI.app';
    platform.exename{2} = 'run_AtlasViewerGUI.sh';
    platform.exenameDesktopPath = [platform.desktopPath, '/AtlasViewerGUI.command'];
    platform.setup_exe{1} = 'setup.app';
    platform.setup_exe{2} = 'run_setup.sh';
    platform.setup_script = 'setup.command';
    platform.createshort_script{1} = 'createShortcut.sh';
    platform.mcrpath = [dirnameHome, 'libs/mcr'];
elseif islinux()
    platform.arch = 'Linux';
    platform.exename{1} = 'AtlasViewerGUI.sh';
    platform.exename{2} = 'run_AtlasViewerGUI.sh';
    platform.exenameDesktopPath = [platform.desktopPath, '/', platform.exename{1}];
    platform.setup_exe{1} = 'setup';
    platform.setup_exe{2} = 'run_setup.sh';
    platform.setup_script = 'setup.sh';
    platform.createshort_script{1} = 'createShortcut.sh';
    platform.mcrpath = [dirnameHome, 'libs/mcr'];
elseif ispc()
    platform.arch = 'Win';
    platform.mc_exe_ext = '.exe';
    platform.exename{1} = 'AtlasViewerGUI.exe';
    platform.exenameDesktopPath = [platform.desktopPath, '/', platform.exename{1}, '.lnk'];
    platform.setup_exe{1} = 'setup.exe';
    platform.setup_exe{2} = 'installtemp';
    platform.setup_script = 'setup.bat';
    platform.createshort_script{1} = 'createShortcut.bat';
    platform.createshort_script{2} = 'createShortcut.vbs';
end


