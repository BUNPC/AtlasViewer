function SD = getSD(nirsobj)

SD = [];
if AVUtils.isproperty(nirsobj, 'SD')
    SD = nirsobj.SD;
    if isempty(SD) && AVUtils.isproperty(nirsobj,'subjs')
        SD = getSD(nirsobj.subjs(1));
    elseif isempty(SD) && AVUtils.isproperty(nirsobj,'runs')
        SD = getSD(nirsobj.runs(1));
    elseif AVUtils.isproperty(nirsobj, 'procInputRun') & AVUtils.isproperty(nirsobj.procInputRun, 'SD')
        SD = nirsobj.procInputRun.SD;
    end
elseif AVUtils.isproperty(nirsobj, 'procInput') & AVUtils.isproperty(nirsobj.procInput, 'SD')
    SD = nirsobj.procInput.SD;
    if isempty(SD) && AVUtils.isproperty(nirsobj,'subjs')
        SD = getSD(nirsobj.subjs(1).procInput);
    elseif isempty(SD) && AVUtils.isproperty(nirsobj,'runs')
        SD = getSD(nirsobj.runs(1).procInput);
    end
end
