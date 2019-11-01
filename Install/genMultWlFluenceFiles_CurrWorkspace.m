function genMultWlFluenceFiles_CurrWorkspace()

rootfluencepath = './Data/Colin/fw/';

if ~exist(rootfluencepath, 'dir')==7
    return;
end

fp = [rootfluencepath, 'fluenceProf*.mat'];
files = dir(fp);
if isempty(files)
    if exist([rootfluencepath, 'fluenceProfs.tar'], 'file')==2
        untar([rootfluencepath, 'fluenceProfs.tar'], rootfluencepath);
    else
        return;
    end
end
files = dir(fp);
if isempty(files)
    return;
end

fprintf('Found fluence files in %s\n', rootfluencepath)
for ii=1:length(files)
    genMultWavelengthSimInFluenceFiles([rootfluencepath, files(ii).name], 2);
end
