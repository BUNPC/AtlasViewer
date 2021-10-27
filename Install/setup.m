function setup()
global h
global nSteps
global dirnameSrc
global dirnameDst

try

    currdir = filesepStandard(pwd);
        
    h = waitbar(0,'Installation Progress ...');
       
    [~, exename] = getAppname();
    setNamespace(exename)
    
    dirnameSrc = currdir;
    dirnameDst = getAppDir('isdeployed');

    cleanup();
    
    main();
    
    % Check that everything was installed properly
    finishInstallGUI(exename);
    
    waitbar(nSteps/nSteps, h);
    close(h);
    
catch ME
    
    printStack(ME)
    cd(currdir)
    if ishandles(h)
        close(h);
    end
    rethrow(ME)
        
end
cd(currdir)


    

% ------------------------------------------------------------
function main()
global h
global nSteps
global iStep
global platform
global logger
global dirnameSrc
global dirnameDst

nSteps = 100;
iStep = 1;

fprintf('dirnameSrc = %s\n', dirnameSrc)
fprintf('dirnameDst = %s\n', dirnameDst)

logger = Logger([dirnameSrc, 'Setup']);

[~, exename] = getAppname();

v = getVernum();
logger.Write('==========================================\n');
logger.Write('Setup script for %s v%s.%s.%s:\n', exename, v{1}, v{2}, v{3});
logger.Write('==========================================\n\n');

logger.Write('Platform params:\n');
logger.Write('  arch: %s\n', platform.arch);
logger.Write('  mc_exe: %s%s\n', platform.mc_exe_name, platform.mc_exe_ext);
logger.Write('  exename: %s\n', platform.exename{1});
logger.Write('  setup_exe: %s\n', platform.setup_exe{1});
logger.Write('  setup_script: %s\n', platform.setup_script);
logger.Write('  dirnameApp: %s\n', platform.dirnameApp);
logger.Write('  mcrpath: %s\n', platform.mcrpath);
logger.Write('  iso2meshmex: %s\n', platform.iso2meshmex{1});
logger.Write('  iso2meshbin: %s\n\n', platform.iso2meshbin);

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
	printStack(ME)
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
for ii = 1:length(platform.exename)
    copyFile([dirnameSrc, platform.exename{ii}],  [dirnameDst, platform.exename{ii}]);
end
copyFile([dirnameSrc, 'AppSettings.cfg'],   dirnameDst);

% Copy all the Colin atlas folder files
copyFile([dirnameSrc, 'headsurf.mesh'],         [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'headsurf2vol.txt'],      [dirnameDst, 'Colin/anatomical']);
copyFile({[dirnameSrc, 'headvol.vox'], [dirnameSrc, 'headvol.vox.gz']}, [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'headvol2ras.txt'],       [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'headvol_dims.txt'],      [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'headvol_tiss_type.txt'], [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'labelssurf.mat'],        [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'labelssurf2vol.txt'],    [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'pialsurf.mesh'],         [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'pialsurf2vol.txt'],      [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'refpts.txt'],            [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'refpts2vol.txt'],        [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'refpts_labels.txt'],     [dirnameDst, 'Colin/anatomical']);
copyFile([dirnameSrc, 'Refpts'], [dirnameDst, 'Refpts']);
copyFile([dirnameSrc, platform.mc_exe_name, '.tar.gz'], [dirnameDst, platform.mc_exe_name]);
copyFile([dirnameSrc, 'Group'], [dirnameDst, 'Group']);

% Check if there a fluence profile to load in this particular search path
if ispathvalid([dirnameSrc, 'fluenceProfs.tar'])
    untar([dirnameSrc, 'fluenceProfs.tar']);
end
fluenceProfFnames = dir([dirnameSrc, 'fluenceProf*.mat']);
for ii=1:length(fluenceProfFnames)
    genMultWavelengthSimInFluenceFiles([dirnameSrc, fluenceProfFnames(ii).name], 2);
    copyFile([dirnameSrc, fluenceProfFnames(ii).name],  [dirnameDst, 'Colin/fw']);
end
copyFile([dirnameSrc, 'projVoltoMesh_brain.mat'], [dirnameDst, 'Colin/fw']);
copyFile([dirnameSrc, 'projVoltoMesh_scalp.mat'], [dirnameDst, 'Colin/fw']);


for ii = 1:length(platform.iso2meshmex)
    % Use dir instead of exist for mex files because of an annoying matlab bug, where a
    % non existent file will be reported as exisiting as a mex file (exist() will return 3)
    % because there are other files with the same name and a .mex extention that do exist.
    % dir doesn't have this problem.
    if ~isempty(dir([dirnameSrc, platform.iso2meshmex{ii}]))
        logger.Write('Copying %s to %s\n', [dirnameSrc, platform.iso2meshmex{ii}], dirnameDst);
        copyFile([dirnameSrc, platform.iso2meshmex{ii}], dirnameDst);
        if isunix()
            system(sprintf('chmod 755 %s', [dirnameDst, '', platform.iso2meshmex{ii}]'));
        end
    else
        logger.Write('ERROR: %s does NOT exist...\n', [dirnameSrc, platform.iso2meshmex{ii}]);
    end
end
copyFile([dirnameSrc, 'Test'], [dirnameDst, 'Test'], 'dir');


createDesktopShortcuts(dirnameSrc, dirnameDst);

waitbar(iStep/nSteps, h); iStep = iStep+1;
pause(2);




% -----------------------------------------------------------------
function err = cleanup()
global dirnameSrc
global dirnameDst

err = 0;

% Uninstall old installation
try
    if exist(dirnameDst,'dir')
        rmdir(dirnameDst, 's');
    end
catch ME
    printStack(ME);
    msg{1} = sprintf('Error: Could not remove old installation folder %s. It might be in use by other applications.\n', dirnameDst);
    msg{2} = sprintf('Try closing and reopening file browsers or any other applications that might be using the\n');
    msg{3} = sprintf('installation folder and then retry installation.');
    menu([msg{:}], 'OK');
    pause(5);
    rethrow(ME)
end

% Change source dir if not on PC
if ~ispc() && ~isdeployed()
    dirnameSrc0 = dirnameSrc;
    
    dirnameSrc = sprintf('~/Downloads/%s_install/', lower(getAppname));
    fprintf('SETUP:    current folder is %s\n', pwd);   
    rmdir_safe(sprintf('~/Desktop/%s_install/', lower(getAppname())));
    rmdir_safe(dirnameSrc);
    rmdir_safe('~/Desktop/Test/');
    
    if ispathvalid(dirnameSrc)
        err = -1;
    end
    if ispathvalid('~/Desktop/%s_install/')
        err = -1;
    end
    if ispathvalid('~/Desktop/Test/')
        err = -1;
    end
       
    copyFile(dirnameSrc0, dirnameSrc);
    cd(dirnameSrc);
end





% -------------------------------------------------------------------
function copyFile(src, dst, type)
global h
global nSteps
global iStep
global logger

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
    logger.Write('Copying %s to %s\n', src, dst);
    copyfile(src, dst);

    if ~isempty(iStep)
        waitbar(iStep/nSteps, h); iStep = iStep+1;
    end
    pause(1);
catch ME
    if ishandles(h)
        close(h);
    end
    printStack(ME);
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
catch ME
    msg{1} = sprintf('Error: Could not create %s shortcuts on Desktop. Exiting installation.', exename);
    menu([msg{:}], 'OK');
    printStack(ME)
    return;    
end

