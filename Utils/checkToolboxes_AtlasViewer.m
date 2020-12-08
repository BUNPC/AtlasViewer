function [r, toolboxes] = checkToolboxes_AtlasViewer()

toolboxes = {};

header{1} = sprintf('==============================================\n');
header{2} = sprintf('List of required toolboxes for AtlasViewerGUI:\n');
header{3} = sprintf('==============================================\n');

% Check for presence of file which already has all the toolboxes
r = true;
filename = getToolboxListFilename('AtlasViewerGUI');
if exist(filename,'file')==2
    fid = fopen(filename);
    if(fid > 0)
        for ii=1:length(header)
            fprintf(header{ii});
        end
        kk=1;
        while 1
            line = fgetl(fid);
            if line==-1
                break;
            end
            toolboxes{kk} = line;
            fprintf('%s\n', toolboxes{kk});
            kk=kk+1;
        end
        fclose(fid);
        fprintf('\n');
        r = checkToolboxes(toolboxes, 'Homer2');
        return;
    end
end

if verLessThan('matlab','8.3')
    r = 4;
    return;
end

msg{1} = sprintf('Unable to find matching toolbox list for the current Matlab release.\n');
msg{2} = sprintf('Do you want to run toolbox discovery to determine which toolboxes are required?\n');
msg{3} = sprintf('It takes 5-10 minutes.\n');
q = menu([msg{:}], 'YES','NO');
if q==2
    r = 3;
    return;
end

exclList = {};

% Change curr folder to AtlasViewerGUI
currdir = pwd;
if ~exist('dirnameApp','var') | isempty(dirnameApp)
    dirnameApp = ffpath('setpaths.m');
end
if dirnameApp(end)~='/' & dirnameApp(end)~='\'
    dirnameApp(end+1)='/';
end
cd(dirnameApp);

% Find all the .m files for AtlasViewerGUI
files = findDotMFiles('.', exclList);
nFiles = length(files);

hwait = waitbar(0, sprintf('Checking toolboxes for %d source files', nFiles));
for ii=1:nFiles
    
    fprintf('Checking ''%s'' for required toolboxes ...\n', files{ii});
    
    % Searching for AtlasViewerGUI toolboxes takes a long time, so it was done
    % beforehand and is already included in toolboxes.
    [~,f,~] = fileparts(files{ii});
    if strcmp(f, 'AtlasViewerGUI')
        continue;
    end
    
    [~, q] = matlab.codetools.requiredFilesAndProducts(files{ii});
    for jj=1:length(q)
        if ~strcmpi(q(jj).Name, 'MATLAB')
            if ~strcellfind(toolboxes, q(jj).Name)
                fprintf('Adding ''%s'' to list of required toolboxes\n', q(jj).Name);
                toolboxes{end+1} = q(jj).Name;
            end
        end
    end
    waitbar(ii/length(files), hwait, sprintf('Checked %d of %d files', ii, nFiles));
end
close(hwait);
fprintf('\n');

cd(currdir);

fid = fopen(filename,'wt');
for ii=1:length(header)
    fprintf(header{ii});
end
for jj=1:length(toolboxes)
    line = sprintf('%s\n', toolboxes{jj});
    fprintf(fid, line);
    fprintf(line);
end
fprintf('\n');
fclose(fid);

r = checkToolboxes(toolboxes, 'AtlasViewer');

