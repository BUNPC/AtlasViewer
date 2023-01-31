function setup()
global h
global nSteps
global dirnameSrc
global dirnameDst

try

    setNamespace('AtlasViewerGUI');
    
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

v = getVernum('AtlasViewerGUI');
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
logger.Write('  iso2meshbin: %s\n\n', filesepStandard(platform.iso2meshbin));

deleteShortcuts();

pause(2);

% Create destination folders
try 
    mkdir(dirnameDst);
catch ME
    msg{1} = sprintf('Error: Could not create installation folder. It might be in use by other applications.\n');
    msg{2} = sprintf('Try closing and reopening file browsers or any other applications that might be using the\n');
    msg{3} = sprintf('installation folder and then retry installation.');
    MenuBox([msg{:}], 'OK');
    close(h);
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
    myCopyFile([dirnameSrc, platform.exename{ii}],  [dirnameDst, platform.exename{ii}]);
end
myCopyFile([dirnameSrc, 'AppSettings.cfg'],   dirnameDst);
myCopyFile([dirnameSrc, 'Data'],         [dirnameDst, 'Data']);
myCopyFile([dirnameSrc, platform.mc_exe_name], [dirnameDst, platform.mc_exe_name]);
myCopyFile([dirnameSrc, 'Group'], [dirnameDst, 'Group']);
myCopyFile([dirnameSrc, 'LastCheckForUpdates.dat'], dirnameDst);

for ii = 1:length(platform.iso2meshmex)
    % Use dir instead of exist for mex files because of an annoying matlab bug, where a
    % non existent file will be reported as exisiting as a mex file (exist() will return 3)
    % because there are other files with the same name and a .mex extention that do exist.
    % dir doesn't have this problem.
    if ~isempty(dir([dirnameSrc, platform.iso2meshmex{ii}]))
        myCopyFile([dirnameSrc, platform.iso2meshmex{ii}], dirnameDst);
        if isunix()
            system(sprintf('chmod 755 %s', [dirnameDst, '', platform.iso2meshmex{ii}]'));
        end
    end
end
myCopyFile([dirnameSrc, 'Test'], [dirnameDst, 'Test']);

createDesktopShortcuts(dirnameSrc, dirnameDst);

waitbar(iStep/nSteps, h); iStep = iStep+1;
pause(2);




% -----------------------------------------------------------------
function err = cleanup()
global dirnameSrc
global dirnameDst
global logger 

err = 0;

logger = [];

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
    MenuBox([msg{:}], 'OK');
    pause(5);
    rethrow(ME)
end

% Change source dir if not on PC
if ~ispc()
    dirnameSrc = sprintf('~/Downloads/%s_install/', lower(getAppname));
    fprintf('SETUP:    current folder is %s\n', pwd);   
    
    if ~isdeployed()
        rmdir_safe(sprintf('~/Desktop/%s_install/', lower(getAppname())));
        if ~pathscompare(dirnameSrc, dirnameSrc0)
            rmdir_safe(dirnameSrc);            
            if ispathvalid(dirnameSrc)
                err = -1;
            end
            myCopyFile(dirnameSrc0, dirnameSrc);
        end
        rmdir_safe('~/Desktop/Test/');
        
        if ispathvalid('~/Desktop/%s_install/')
            err = -1;
        end
        if ispathvalid('~/Desktop/Test/')
            err = -1;
        end
        
        cd(dirnameSrc);
    end
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
    MenuBox([msg{:}], 'OK');
    printStack(ME)
    return;    
end

