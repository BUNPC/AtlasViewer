function b = probeHas3DLandmarkRegistration()
global atlasViewer
b= false;

dataTree = atlasViewer.dataTree;
if ~isempty(dataTree)
    procElem = dataTree.currElem;
    if strcmp(procElem.type,'sess')
        dataTree.SetCurrElem(procElem.iGroup, procElem.iSubj, procElem.iSess, 1);
        dataTree.LoadCurrElem();
        procElem = dataTree.currElem;
        dataTree.SetCurrElem(procElem.iGroup, procElem.iSubj, procElem.iSess);
        dataTree.LoadCurrElem();
    elseif strcmp(procElem.type,'subj')
        dataTree.SetCurrElem(procElem.iGroup, procElem.iSubj, 1, 1);
        dataTree.LoadCurrElem();
        procElem = dataTree.currElem;
        dataTree.SetCurrElem(procElem.iGroup, procElem.iSubj);
        dataTree.LoadCurrElem();
    elseif strcmp(procElem.type,'group')
        dataTree.SetCurrElem(procElem.iGroup, 1, 1, 1);
        dataTree.LoadCurrElem();
        procElem = dataTree.currElem;
        dataTree.SetCurrElem(procElem.iGroup);
       dataTree.LoadCurrElem();
    end
    probe_data = procElem.acquired.probe;
    if ~isempty(probe_data.landmarkPos3D) && ~isempty(probe_data.landmarkPos3D)
        b = true;
    end
end