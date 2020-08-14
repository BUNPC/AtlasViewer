function currElem = LoadCurrElem(group, iSubj)

currElem = [];
if ~exist('iSubj','var') || isempty(iSubj)
    iSubj = 0;
end
if isempty(group)
    return
end

if iSubj==0
    currElem = group;
else
    currElem = group.subjs(iSubj);
end

currElem.LoadSubBranch();

