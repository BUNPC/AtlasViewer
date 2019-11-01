function [mc_exepath, mc_exename, mc_appname, ext] = searchDirForMCApp(mc_exepath, platform)

mc_exename = '';
mc_appname = '';
ext = '';

files = dir([mc_exepath, '/*']);
for ii=1:length(files)
    
    if ~files(ii).isdir
        k = find(files(ii).name=='.');
        if isempty(k)
            possible = files(ii).name;
            ext = '';
        else
            possible = files(ii).name(1:k-1);
            ext = files(ii).name(k:end);
        end
    else
        possible = files(ii).name;
    end
    
    % Check to see if the folder or file is the name of a MC app
    if isMCapp(possible)
        
        % Yes it's the name of an MC app - however we don't yet know if the
        % actual executable exists. 
        mc_appname = possible;
        
        % If it's a file, then we have our answer
        if ~files(ii).isdir
            mc_exename = [possible, ext];
            return;
        end
        
        % If it's a folder, then look under it to see if executable exists.
        % Even if it does not we can assume that the MC folder exists. We could 
        % try to build the exe file if it doesn't exist. 
        possible_exepath = sprintf('%s%s/bin/%s/', mc_exepath, possible, platform);
        if exist(possible_exepath,'dir')==7
            mc_exepath = possible_exepath;
            if exist([mc_exepath, possible, ext],'file')==2
                mc_exename = [possible, ext];
                return;
            end
        end
        
    end
end

% If there are no files or folders to look through in mc_exepath folder, 
% then examine mc_exepath string to find the app name
mc_appnamelist = mcAppList();
if exist(mc_exepath,'dir')==7
    for ii=1:length(mc_appnamelist)
        k = findstr(mc_exepath, mc_appnamelist{ii});
        if ~isempty(k)
            mc_appname = mc_appnamelist{ii};
        end
    end
end
