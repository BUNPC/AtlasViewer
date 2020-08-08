function currElem = LoadCurrElem(group, iSubj)
if ~exist('iSubj','var') || isempty(iSubj)
    iSubj = 0;
end
 
if iSubj==0
    currElem = group;
else
    currElem = group.subjs(iSubj);
end
warning('off', 'MATLAB:load:cannotInstantiateLoadedVariable');
warning('off', 'MATLAB:load:classNotFound');
currElem.LoadSubBranch();
warning('on', 'MATLAB:load:cannotInstantiateLoadedVariable');
warning('on', 'MATLAB:load:classNotFound');
