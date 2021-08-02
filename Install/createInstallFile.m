function createInstallFile(options)

setNamespace('AtlasViewerGUI')

if ~exist('options','var') | isempty(options)
    options = 'all';
end

% Find installation path and add it to matlab search paths
dirnameApp = getAppDir;
if isempty(dirnameApp)
    MessageBox('Cannot create installation package. Could not find root application folder.');
    return;
end
dirnameInstall = filesepStandard(fileparts(which('createInstallFile.m')));
if isempty(dirnameInstall)
    MessageBox('Cannot create installation package. Could not find root installation folder.');
    return;
end
addpath(dirnameInstall, '-end')
cd(dirnameInstall);

% Start with a clean slate
cleanup(dirnameInstall, dirnameApp, 'start');

% Set the executable names based on the platform type
platform = setplatformparams();

if exist([dirnameInstall, 'homer3_install'],'dir')
    rmdir_safe([dirnameInstall, 'homer3_install']);
end
if exist([dirnameInstall, 'atlasviewer_install.zip'],'file')
    delete([dirnameInstall, 'atlasviewer_install.zip']);
end
mkdir([dirnameInstall, 'atlasviewer_install']);

% Generate executables
if ~strcmp(options, 'nobuild')
	Buildme();
	Buildme_Setup();
    if islinux()
        perl('./makesetup.pl','./run_setup.sh','./setup.sh');
    elseif ismac()
        perl('./makesetup.pl','./run_setup.sh','./setup.command');
    end
end

% Zip up MC application 
mc_exe_dir = [dirnameApp,  'ForwardModel/', platform.mc_exe_name];
if exist(mc_exe_dir,'dir') == 7
    tar([dirnameInstall, 'atlasviewer_install/', platform.mc_exe_name, '.tar'], mc_exe_dir);
    gzip([dirnameInstall, 'atlasviewer_install/', platform.mc_exe_name, '.tar']);
    delete([dirnameInstall, 'atlasviewer_install/', platform.mc_exe_name, '.tar']);
end

for ii=1:length(platform.exename)
    if exist([dirnameInstall, platform.exename{ii}],'file')
        copyfile([dirnameInstall, platform.exename{ii}], [dirnameInstall, 'atlasviewer_install/', platform.exename{ii}]);
    end
end
if exist([dirnameInstall, platform.setup_script],'file')==2
    copyfile([dirnameInstall, platform.setup_script], [dirnameInstall, 'atlasviewer_install']);
    if ispc()
        copyfile([dirnameInstall, platform.setup_script], [dirnameInstall, 'atlasviewer_install/Autorun.bat']);
    end
end
for ii=1:length(platform.setup_exe)
    if exist([dirnameInstall, platform.setup_exe{ii}],'file')
        if ispc()
            copyfile([dirnameInstall, platform.setup_exe{1}], [dirnameInstall, 'atlasviewer_install/installtemp']);
        else
            copyfile([dirnameInstall, platform.setup_exe{ii}], [dirnameInstall, 'atlasviewer_install/', platform.setup_exe{ii}]);
        end
	end
end
if exist([dirnameApp, 'Group/FuncRegistry'],'dir')
    try
        copyfile([dirnameApp, 'Group/FuncRegistry'], [dirnameInstall, 'atlasviewer_install/Group/FuncRegistry']);
    catch
        mkdir([dirnameInstall, 'atlasviewer_install/Group'])
        mkdir([dirnameInstall, 'atlasviewer_install/Group/FuncRegistry'])
        copyfile([dirnameApp, 'Group/FuncRegistry'], [dirnameInstall, 'atlasviewer_install/Group/FuncRegistry']);
    end
end
if exist([dirnameApp, 'Test'],'dir')
    copyfile([dirnameApp, 'Test'], [dirnameInstall, 'atlasviewer_install/Test']);
end

for ii=1:length(platform.createshort_script)
    if exist([dirnameInstall, platform.createshort_script{ii}],'file')
        copyfile([dirnameInstall, platform.createshort_script{ii}], [dirnameInstall, 'atlasviewer_install']);
    end
end
if exist(getAtlasDir(),'dir')
    copyfile([getAtlasDir(), 'anatomical/*.*'], [dirnameInstall, 'atlasviewer_install']);
    copyfile([getAtlasDir(), 'fw/*.*'], [dirnameInstall, 'atlasviewer_install']);
end

if exist([dirnameInstall, 'makefinalapp.pl'],'file')
    copyfile([dirnameInstall, 'makefinalapp.pl'], [dirnameInstall, 'atlasviewer_install']);
end

if exist([dirnameInstall, 'generateDesktopPath.bat'],'file')
    copyfile([dirnameInstall, 'generateDesktopPath.bat'], [dirnameInstall, 'atlasviewer_install']);
end

if exist([dirnameInstall, 'README.txt'],'file')
    copyfile([dirnameInstall, 'README.txt'], [dirnameInstall, 'atlasviewer_install']);
end

for ii=1:length(platform.iso2meshmex)
    % Use dir instead of exist for mex files because of an annoying matlab bug, where a  
    % non existent file will be reported as exisiting as a mex file (exist() will return 3)
    % because there are other files with the same name and a .mex extention that do exist. 
    % dir doesn't have this problem.
    if ~isempty(dir([platform.iso2meshbin, platform.iso2meshmex{ii}]))
        copyfile([platform.iso2meshbin, platform.iso2meshmex{ii}], [dirnameInstall, 'atlasviewer_install']);
    else
        menu(sprintf('Warning: could not find mex file %s', platform.iso2meshmex{ii}), 'OK');
    end
end



% Zip it all up into a single installation file
zip([dirnameInstall, 'atlasviewer_install.zip'], [dirnameInstall, 'atlasviewer_install']);

% Clean up 
fclose all;
cleanup(dirnameInstall, dirnameApp);

