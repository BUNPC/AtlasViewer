function av_createInstallFile(options)

if ~exist('options','var') | isempty(options)
    options = 'all';
end
if exist('./Install','dir')
    cd('./Install');
end

% Find installation path and add it to matlab search paths
dirnameInstall = fileparts(which('createInstallFile.m'));
if isempty(dirnameInstall)
    m1 = sprintf('Cannot create installation package.\n');
    menu([m1],'OK');
    return;
end
[pp,fs] = getpathparts(dirnameInstall);
dirnameApp = buildpathfrompathparts(pp(1:end-1), fs(1:end-1,:));
if isempty(dirnameApp)
    m1 = sprintf('Cannot create installation package.\n');
    menu([m1],'OK');
    return;
end
if dirnameInstall(end)~='/' & dirnameInstall(end)~='\'
    dirnameInstall(end+1)='/';
end
if dirnameApp(end)~='/' & dirnameApp(end)~='\'
    dirnameApp(end+1)='/';
end
addpath(dirnameInstall, '-end')

cd(dirnameInstall);

% Start with a clean slate
av_cleanup(dirnameInstall, dirnameApp);

% Set the executable names based on the platform type
platform = av_setplatformparams();

if exist([dirnameInstall, 'atlasviewer_install'],'dir')
    rmdir([dirnameInstall, 'atlasviewer_install'],'s');
end
if exist([dirnameInstall, 'atlasviewer_install.zip'],'file')
    delete([dirnameInstall, 'atlasviewer_install.zip']);
end
mkdir([dirnameInstall, 'atlasviewer_install']);

% Generate executables
if ~strcmp(options, 'nobuild')
	Buildme_av_setup(pwd);
	Buildme_AtlasViewerGUI(dirnameApp);
    if islinux()
        perl('./makesetup.pl','./run_setup.sh','./setup.sh');
    elseif ismac()
        perl('./makesetup.pl','./run_setup.sh','./setup.command');
    end
end


% Zip up MC application 
if exist([dirnameApp,  platform.mc_exe_name],'dir')
    tar([dirnameInstall, 'atlasviewer_install/', platform.mc_exe_name, '.tar'], [dirnameApp, platform.mc_exe_name]);
    gzip([dirnameInstall, 'atlasviewer_install/', platform.mc_exe_name, '.tar']);
    delete([dirnameInstall, 'atlasviewer_install/', platform.mc_exe_name, '.tar']);
end

for ii=1:length(platform.atlasviewer_exe)
    if exist([dirnameInstall, platform.atlasviewer_exe{ii}],'file')
        copyfile([dirnameInstall, platform.atlasviewer_exe{ii}], [dirnameInstall, 'atlasviewer_install/', platform.atlasviewer_exe{ii}]);
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
av_cleanup(dirnameInstall, dirnameApp);



