function setup()
global h
global nSteps

[~, exename] = getAppname();

setNamespace(exename)

h = waitbar(0,'Installation Progress ...');

main();

% Check that everything was installed properly
r = finishInstallGUI(exename);

waitbar(nSteps/nSteps, h);
close(h);

cleanup();



% ------------------------------------------------------------
function main()
global h
global nSteps
global iStep
global platform

nSteps = 100;
iStep = 1;

[appname, exename] = getAppname();

if ismac()
    dirnameSrc = sprintf('~/Downloads/%s_install/', lower(appname));
else
	dirnameSrc = [pwd, '/'];
end
dirnameDst = getAppDir('isdeployed');

% Uninstall
try
    if exist(dirnameDst,'dir')
        rmdir(dirnameDst, 's');
    end
catch ME
    close(h);
    printStack();
    msg{1} = sprintf('Error: Could not remove old installation folder %s. It might be in use by other applications.\n', dirnameDst);
    msg{2} = sprintf('Try closing and reopening file browsers or any other applications that might be using the\n');
    msg{3} = sprintf('installation folder and then retry installation.');
    menu([msg{:}], 'OK');
    pause(5);
    rethrow(ME)
end


v = getVernum();
fprintf('=================================\n');
fprintf('Setup script for %s v%s.%s:\n', exename, v{1}, v{2});
fprintf('=================================\n\n');

fprintf('Platform params:\n');
fprintf('  arch: %s\n', platform.arch);
fprintf('  mc_exe: %s%s\n', platform.mc_exe_name, platform.mc_exe_ext);
fprintf('  exename: %s\n', platform.exename{1});
fprintf('  setup_exe: %s\n', platform.setup_exe{1});
fprintf('  setup_script: %s\n', platform.setup_script);
fprintf('  dirnameApp: %s\n', platform.dirnameApp);
fprintf('  mcrpath: %s\n', platform.mcrpath);
fprintf('  iso2meshmex: %s\n', platform.iso2meshmex{1});
fprintf('  iso2meshbin: %s\n\n', platform.iso2meshbin);

deleteShortcuts();

pause(2);

% Create destination folders
try 
    mkdir(dirnameDst);
catch ME
    msg{1} = sprintf('Error: Could not create installation folder. It might be in use by other applications.\n');
    msg{2} = sprintf('Try closing and reopening file browsers or any other applications that might be using the\n');
    msg{3} = sprintf('installation folder and then retry installation.');
    menu([msg{:}], 'OK');
    close(h);
    rethrow(ME)
end

try 
    mkdir([dirnameDst, 'Colin']);
    mkdir([dirnameDst, 'Colin/anatomical']);
    mkdir([dirnameDst, 'Colin/fw']);
    mkdir([dirnameDst, platform.mc_exe_name]);
    mkdir([dirnameDst, 'Test']);
catch ME
    close(h);
    msg{1} = sprintf('Error: Could not create installtion subfolder. Installtion folder might be in use by other applications.\n');
    msg{2} = sprintf('Try closing and reopening file browsers or any other applications that might be using the\n');
    msg{3} = sprintf('installation folder and then retry installation.');
    menu([msg{:}], 'OK');
	pause(5);
    rethrow(ME)
end


% Get full paths for source and destination directories
dirnameSrc = fullpath(dirnameSrc);
dirnameDst = fullpath(dirnameDst);

% Copy files from source folder to destination installation folder

% Important: For next 2 copyfile calls make sure to keep the destination
% the way it is, with the destination file name specified. This is important
% for mac installation because the executable is actually a directory.
% Copyfile only copies the contents of a folder so to copy the whole thing
% you need to specify the root foder same as the source.
for ii=1:length(platform.exename)
    copyFileToInstallation([dirnameSrc, platform.exename{ii}],  [dirnameDst, platform.exename{ii}]);
end


% Copy all the Colin atlas folder files
copyFileToInstallation([dirnameSrc, 'headsurf.mesh'],         [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'headsurf2vol.txt'],      [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation({[dirnameSrc, 'headvol.vox'], [dirnameSrc, 'headvol.vox.gz']}, [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'headvol2ras.txt'],       [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'headvol_dims.txt'],      [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'headvol_tiss_type.txt'], [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'labelssurf.mat'],        [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'labelssurf2vol.txt'],    [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'pialsurf.mesh'],         [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'pialsurf2vol.txt'],      [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'refpts.txt'],            [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'refpts2vol.txt'],        [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, 'refpts_labels.txt'],     [dirnameDst, 'Colin/anatomical']);
copyFileToInstallation([dirnameSrc, platform.mc_exe_name, '.tar.gz'], [dirnameDst, platform.mc_exe_name]);
copyFileToInstallation([dirnameSrc, 'Group'], [dirnameDst, 'Group']);


% Check if there a fluence profile to load in this particular search path
if ~isempty(dir([dirnameSrc, 'fluenceProfs.tar']))
    untar('fluenceProfs.tar');
end
fluenceProfFnames = dir([dirnameSrc, 'fluenceProf*.mat']);
for ii=1:length(fluenceProfFnames)
    genMultWavelengthSimInFluenceFiles([dirnameSrc, fluenceProfFnames(ii).name], 2);
    copyFileToInstallation([dirnameSrc, fluenceProfFnames(ii).name],  [dirnameDst, 'Colin/fw']);
end
copyFileToInstallation([dirnameSrc, 'projVoltoMesh_brain.mat'], [dirnameDst, 'Colin/fw']);
copyFileToInstallation([dirnameSrc, 'projVoltoMesh_scalp.mat'], [dirnameDst, 'Colin/fw']);


for ii=1:length(platform.iso2meshmex)
    % Use dir instead of exist for mex files because of an annoying matlab bug, where a
    % non existent file will be reported as exisiting as a mex file (exist() will return 3)
    % because there are other files with the same name and a .mex extention that do exist.
    % dir doesn't have this problem.
    if ~isempty(dir([dirnameSrc, platform.iso2meshmex{ii}]))
        fprintf('Copying %s to %s\n', [dirnameSrc, platform.iso2meshmex{ii}], dirnameDst);
        copyFileToInstallation([dirnameSrc, platform.iso2meshmex{ii}], dirnameDst);
        if isunix()
            system(sprintf('chmod 755 %s', [dirnameDst, '', platform.iso2meshmex{ii}]'));
        end
    else
        fprintf('ERROR: %s does NOT exist...\n', [dirnameSrc, platform.iso2meshmex{ii}]);
    end
end
copyFileToInstallation([dirnameSrc, 'Test'], [dirnameDst, 'Test'], 'dir');


createDesktopShortcuts(dirnameSrc, dirnameDst);

waitbar(iStep/nSteps, h); iStep = iStep+1;
pause(2);




% -----------------------------------------------------------------
function cleanup()
if ismac()
    rmdir_safe(sprintf('~/Desktop/%s_install/', lower(getAppname())));
    rmdir_safe('~/Downloads/%s_install/', lower(getAppname()));
end



% -------------------------------------------------------------------
function copyFileToInstallation(src, dst, type)
global h
global nSteps
global iStep

if ~exist('type', 'var')
    type = 'file';
end

try
    % If src is one of several possible filenames, then src to any one of
    % the existing files.
    if iscell(src)
        for ii=1:length(src)
            if ~isempty(dir(src{ii}))
                src = src{ii};
                break;
            end
        end
    end
    
    assert(logical(exist(src, type)));
    
    % Check if we need to untar the file 
    k = findstr(src,'.tar.gz'); %#ok<FSTR>
    if ~isempty(k)
        untar(src,fileparts(src));
        src = src(1:k-1);
    end
    
    % Copy file from source to destination folder
    fprintf('Copying %s to %s\n', src, dst);
    copyfile(src, dst);

    waitbar(iStep/nSteps, h); iStep = iStep+1;
    pause(1);
catch ME
    close(h);
    printStack();
    if iscell(src)
        src = src{1};
    end
    menu(sprintf('Error: Could not copy %s to installation folder.', src), 'OK');
    pause(5);
    rethrow(ME);
end




% --------------------------------------------------------------
function deleteShortcuts()
global platform

if exist(platform.exenameDesktopPath, 'file')
    try
        delete(platform.exenameDesktopPath);
    catch
    end
end
if exist([platform.desktopPath, '/Test'], 'dir')
    try
        rmdir([platform.desktopPath, '/Test'], 's');
    catch
    end
end



% ---------------------------------------------------------
function createDesktopShortcuts(dirnameSrc, dirnameDst)
[~, exename] = getAppname();
try
    if ispc()
        
        k = dirnameDst=='/';
        dirnameDst(k)='\';
        
        cmd = sprintf('call "%s\\createShortcut.bat" "%s" %s.exe', dirnameSrc(1:end-1), dirnameDst, exename);
        system(cmd);
              
    elseif islinux()
        
        cmd = sprintf('sh %s/createShortcut.sh sh', dirnameSrc(1:end-1));        
        system(cmd);
        
    elseif ismac()
        
        cmd = sprintf('sh %s/createShortcut.sh command', dirnameSrc(1:end-1));
        system(cmd);
        
    end
catch
    msg{1} = sprintf('Error: Could not create %s shortcuts on Desktop. Exiting installation.', exename);
    menu([msg{:}], 'OK');
    return;    
end

