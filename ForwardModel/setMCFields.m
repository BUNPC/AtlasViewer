function fwmodel = setMCFields(fwmodel, mc_exepath, mc_exename, mc_appname, mc_exename_ext)

if exist(mc_exepath,'dir')==7
    fwmodel.mc_exepath = mc_exepath;
end
if exist([mc_exepath, mc_exename],'file')==2
    fwmodel.mc_exename = mc_exename;
end

if ~isempty(mc_exename)
    fwmodel.mc_appname = mc_appname;
    fwmodel.mc_exename_ext = mc_exename_ext;
end

fwmodel.mc_rootpath = mc_exename;
k = findstr(mc_exepath, mc_appname);
if ~isempty(k)
    fwmodel.mc_rootpath = mc_exepath(1:k+length(mc_appname));
end
