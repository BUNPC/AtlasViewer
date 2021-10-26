function createInstallFile(options)
global installfilename
global platform

platform = [];

% Start with a clean slate
cleanup('','','start');

installfilename = sprintf('%s_install', lower(getAppname()));
[~, exename] = getAppname();

setNamespace(exename)

if ~exist('options','var') || isempty(options)
    options = 'all';
end

% Find installation path and add it to matlab search paths
dirnameApp = getAppDir();
if isempty(dirnameApp)
    MessageBox('Cannot create installation package. Could not find root application folder.');
    deleteNamespace(exename)
    return;
end
dirnameInstall = filesepStandard(fileparts(which('createInstallFile.m')));
if isempty(dirnameInstall)
    MessageBox('Cannot create installation package. Could not find root installation folder.');
    deleteNamespace(exename)
    return;
end
addpath(dirnameInstall, '-end')
cd(dirnameInstall);

% Set the executable names based on the platform type
platform = setplatformparams();

if exist([dirnameInstall, installfilename],'dir')
    rmdir_safe([dirnameInstall, installfilename]);
end
if exist([dirnameInstall, installfilename, '.zip'],'file')
    delete([dirnameInstall, installfilename, '.zip']);
end
mkdir([dirnameInstall, installfilename]);

% Generate executables
if ~strcmp(options, 'nobuild')
    Buildme_Setup();
    Buildme();
    if ~ispc()
        c = str2cell(version(),'.');
        mcrver = sprintf('v%s%s', c{1}, c{2});
        if islinux()
            perl('./makesetup.pl','./run_setup.sh','./setup.sh', mcrver);
        elseif ismac()
            perl('./makesetup.pl','./run_setup.sh','./setup.command', mcrver);
        end
    end
end


% Zip up MC application 
mc_exe_dir = [dirnameApp,  'ForwardModel/', platform.mc_exe_name];
if exist(mc_exe_dir,'dir') == 7
    tar([dirnameInstall, installfilename, '/', platform.mc_exe_name, '.tar'], mc_exe_dir);
    gzip([dirnameInstall, installfilename, '/', platform.mc_exe_name, '.tar']);
    delete([dirnameInstall, installfilename, '/', platform.mc_exe_name, '.tar']);
end

for ii = 1:length(platform.exename)
    if exist([dirnameInstall, platform.exename{ii}],'file')
        copyfile([dirnameInstall, platform.exename{ii}], [dirnameInstall, installfilename, '/', platform.exename{ii}]);
    end
end
if exist([dirnameInstall, platform.setup_script],'file')==2
    copyfile([dirnameInstall, platform.setup_script], [dirnameInstall, installfilename]);
end
for ii=1:length(platform.setup_exe)
    if exist([dirnameInstall, platform.setup_exe{ii}],'file')
        if ispc()
            copyfile([dirnameInstall, platform.setup_exe{1}], [dirnameInstall, installfilename, '/installtemp']);
        else
            copyfile([dirnameInstall, platform.setup_exe{ii}], [dirnameInstall, installfilename, '/', platform.setup_exe{ii}]);
        end
    end
end
if exist([dirnameApp, 'Group/FuncRegistry'],'dir')
    try
        copyfile([dirnameApp, 'Group/FuncRegistry'], [dirnameInstall, installfilename, '/Group/FuncRegistry']);
    catch
        mkdir([dirnameInstall, installfilename, '/Group'])
        mkdir([dirnameInstall, installfilename, '/Group/FuncRegistry'])
        copyfile([dirnameApp, 'Group/FuncRegistry'], [dirnameInstall, installfilename, '/Group/FuncRegistry']);
    end
end
if exist([dirnameApp, 'Refpts/10-5-System_Mastoids_EGI129.csd'],'file')
    mkdir([dirnameInstall, installfilename, '/Refpts'])
    copyfile([dirnameApp, 'Refpts/10-5-System_Mastoids_EGI129.csd'], [dirnameInstall, installfilename, '/Refpts']);
end
if exist([dirnameApp, 'Test'],'dir')
    copyfile([dirnameApp, 'Test'], [dirnameInstall, installfilename, '/Test']);
end

for ii=1:length(platform.createshort_script)
    if exist([dirnameInstall, platform.createshort_script{ii}],'file')
        copyfile([dirnameInstall, platform.createshort_script{ii}], [dirnameInstall, installfilename]);
    end
end
if exist([dirnameApp, 'AppSettings.cfg'],'file')
    copyfile([dirnameApp, 'AppSettings.cfg'], [dirnameInstall, installfilename]);
end

if exist(getAtlasDir(),'dir')
    copyfile([getAtlasDir(), 'anatomical/*.*'], [dirnameInstall, installfilename]);
    copyfile([getAtlasDir(), 'fw/*.*'], [dirnameInstall, installfilename]);
end

if exist([dirnameInstall, 'makefinalapp.pl'],'file')
    copyfile([dirnameInstall, 'makefinalapp.pl'], [dirnameInstall, installfilename]);
end

if exist([dirnameInstall, 'uninstall.bat'],'file')
    copyfile([dirnameInstall, 'uninstall.bat'], [dirnameInstall, installfilename]);
end

if exist([dirnameInstall, 'generateDesktopPath.bat'],'file')
    copyfile([dirnameInstall, 'generateDesktopPath.bat'], [dirnameInstall, installfilename]);
end

if exist([dirnameInstall, 'README.txt'],'file')
    copyfile([dirnameInstall, 'README.txt'], [dirnameInstall, installfilename]);
end

for ii = 1:length(platform.iso2meshmex)
    % Use dir instead of exist for mex files because of an annoying matlab bug, where a  
    % non existent file will be reported as exisiting as a mex file (exist() will return 3)
    % because there are other files with the same name and a .mex extention that do exist. 
    % dir doesn't have this problem.
    if ~isempty(dir([platform.iso2meshbin, platform.iso2meshmex{ii}]))
        copyfile([platform.iso2meshbin, platform.iso2meshmex{ii}], [dirnameInstall, installfilename]);
    else
        menu(sprintf('Warning: could not find mex file %s', platform.iso2meshmex{ii}), 'OK');
    end
end

% Zip it all up into a single installation file
zip([dirnameInstall, installfilename, '.zip'], [dirnameInstall, installfilename]);

% Clean up 
deleteNamespace(exename)
fclose all;
cleanup(dirnameInstall, dirnameApp);


