function Buildme_diagnostics(appName, inclList, exclList, flags)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Buildme allows building of the current directories project in 
% without having to change the output directory or update the .m 
% files list, every time (as seems to be the case with deploytool)
%
% Also it finds all the .m files under the current directory 
%

DEBUG = 1;

currDir = pwd;

% Args 
if ~exist('appName','var')
    [pp,fs] = getpathparts(currDir);
    appName = pp{end};
end
if ~exist('exclList','var')
    exclList = {};
end
if ~exist('flags','var')
    flags = {};
end

% Matlab compiler generates a readme file that overwrites the atlasviewer one
% that already xists. Before we start build , move readme to temp file and 
% at end of build delete the newly generated readme and move the temp one 
% back. 
if exist('./README.txt','file')
    movefile('./README.txt', 'TEMP.txt');
end

% Find main .m file
appDotMFilesStr = '';
sanity = 100;
while ~exist(appDotMFilesStr, 'file')
    
    appDotMFileMain = sprintf('%s.m', appName);
    targetName = sprintf('.%s%s.exe', filesep, appName);
    
    % Check to make sure main .m file exists
    if ~exist(appDotMFileMain,'file')
        q = menu(sprintf('Could not find the main application file %s.m. Please locate the main application file.', appName), 'OK');
        [filenm, pathnm] = uigetfile({'*.m'}, 'Select main .m file');
        if filenm==0
            return;
        end
        [~, appName, ext] = fileparts(filenm);
        appDotMFileMain = [pathnm, filenm];
        appDotMFilesStr = appDotMFileMain;
    else
        appDotMFilesStr = sprintf('%s%s%s', currDir, filesep, appDotMFileMain');
    end
    
    sanity = sanity-1;
    if sanity<=0
        return;
    end
   
end
appDotMFilesStr = sprintf('-v %s', appDotMFileMain');

% Get all .m files which will go into making the app executable
appDotMFiles = findDotMFiles('.', exclList);
for ii=1:length(inclList)
    appDotMFiles = [appDotMFiles, findDotMFiles(inclList{ii}, exclList)];
end

% Create compile switches string
compileSwitches = '';
for ii=1:length(flags)
    compileSwitches = [compileSwitches, flags{ii}, ' '];
end
compileSwitches = [compileSwitches, ' -w enable:specified_file_mismatch'];
compileSwitches = [compileSwitches, ' -w enable:repeated_file'];
compileSwitches = [compileSwitches, ' -w enable:switch_ignored'];
compileSwitches = [compileSwitches, ' -w enable:missing_lib_sentinel'];
compileSwitches = [compileSwitches, ' -w enable:demo_license'];

%%% Go through all the apps, contruct a string listing all the .m files 
%%% on which each app depends and then compile the app using mcc.


% Remove main m file and remove Buildme.m from app files list 
appDotMFiles = removeEntryFromList(appDotMFileMain, appDotMFiles);
appDotMFiles = removeEntryFromList('Buildme.m', appDotMFiles);

% Construct files list portion of build command
if DEBUG
    fid = fopen('Buildme.log','w');
end
for jj=2:length(appDotMFiles)
    appDotMFilesStr = sprintf('%s -a ''%s''', appDotMFilesStr, appDotMFiles{jj});
    if DEBUG
        fprintf(fid, '%s\n', appDotMFiles{jj});
    end
end

% Complete the final build command and execute it
h = waitbar(0, 'Debugging build...');
n = length(appDotMFiles);
for jj=1:floor(n/2)
    [~, appName, ~] = fileparts(appDotMFiles{jj});
    waitbar(jj/(n/2),h, sprintf('Compiling %s.m: %d of %d', appName, jj, n/2));

    buildcmdstr = sprintf('mcc -o %s -W main:%s -T link:exe -d ''%s'' %s %s', appName, appName, [currDir, '/build'], compileSwitches, appDotMFiles{jj});
    disp(buildcmdstr);
    eval(buildcmdstr);
end
close(h);


% Delete useless readme generated by mcc and replace it with our own
% readme.txt that already exsisted
if exist('./README.txt','file')
    delete('./README.txt');
end
if exist('./TEMP.txt','file')
    movefile('TEMP.txt','./README.txt');
end





