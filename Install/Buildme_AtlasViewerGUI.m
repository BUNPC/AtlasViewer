function Buildme_AtlasViewerGUI(dirnameApp)

platform = setplatformparams();

if  ~exist('dirnameApp','var') || isempty(dirnameApp)
    dirnameApp = filesepStandard(ffpath('AtlasViewerGUI.m'));
end
dirnameInstall = filesepStandard(pwd);
cd(dirnameApp);

Buildme('AtlasViewerGUI', {}, {'.git','Install','FuncRegistry','UserFunctions'});
for ii=1:length(platform.exename)
    if exist(['./',  platform.exename{ii}],'file')
        movefile(['./',  platform.exename{ii}], dirnameInstall);
    end
end

cd(dirnameInstall);

