function fwmodel = findMCapp(fwmodel, argExtern)

if ~exist('argExtern','var')
    argExtern={};
end
mc_appnamelist = mcAppList();
dirnameApp = getAppDir();

%%%% SEARCH 1: Check external args for user supplied MC app root folder 
if length(argExtern)>2 & ~isempty(argExtern{3})
    mc_exepath = argExtern{3};
    [mc_exepath, mc_exename, mc_appname, ext] = searchDirForMCApp(mc_exepath, fwmodel.platform);
    fwmodel = setMCFields(fwmodel, mc_exepath, mc_exename, mc_appname, ext);
    if ~isempty(mc_exename)
        return;
    end
end

% Since it doesn't exist, try to build mc_exename
fwmodel = buildMC(fwmodel);
if ~isempty(fwmodel.mc_exename)    
    return;
end


%%%% SEARCH 2: Check installation folder for MC app 
[mc_exepath, mc_exename, mc_appname, ext] = searchDirForMCApp(dirnameApp, fwmodel.platform);
fwmodel = setMCFields(fwmodel, mc_exepath, mc_exename, mc_appname, ext);
if ~isempty(mc_exename)
    return;
end

% Since it doesn't exist, try to build mc_exename
fwmodel = buildMC(fwmodel);
if ~isempty(fwmodel.mc_exename)    
    return;
end


%%%% SEARCH 3: Try to locate MC app root folder using matlab search paths
foos = which('AtlasViewerGUI.m');
if ~isempty(foos)
    [pp,fs] = getpathparts(foos);
    foos = buildpathfrompathparts(pp(1:end-1),fs(1:end-1,:));
    for ii=1:length(mc_appnamelist)
        mc_exepath = sprintf('/%s/bin/%s/', foos, mc_appnamelist{ii}, fwmodel.platform);
        [mc_exepath, mc_exename, mc_appname, ext] = searchDirForMCApp(mc_exepath, fwmodel.platform);
        fwmodel = setMCFields(fwmodel, mc_exepath, mc_exename, mc_appname, ext);
        if ~isempty(fwmodel.mc_exename)
            return;
        end
        if ~isempty(fwmodel.mc_exepath)
            break;
        end
    end
end

% Since it doesn't exist, try to build mc_exename
fwmodel = buildMC(fwmodel);
if ~isempty(fwmodel.mc_exename)    
    return;
end


%%%% SEARCH 4: Last resort: If none of the above locate MC app then ask user where it is. 
while 1
    pause(.1)
    [filenm, pathnm] = uigetfile({'*'; '*.exe'}, ['Monte Carlo executable not found. Please select Monte Carlo executable.']);
    if filenm==0
        return;
    end
    
    % Do a few basic error checks
    if istextfile(filenm)
        q = menu('Selected file not an executable. Try again', 'OK', 'Cancel');
        if q==2
            return;
        else
            continue;
        end
    end    
    break;
end
[mc_exepath, mc_exename, mc_appname, ext] = searchDirForMCApp(pathnm, fwmodel.platform);
fwmodel = setMCFields(fwmodel, mc_exepath, mc_exename, mc_appname, ext);
if ~isempty(fwmodel.mc_exename)    
    return;
end

