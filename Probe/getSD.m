function SD = getSD(nirsobj)

SD = [];
if isproperty(nirsobj, 'SD')
    SD = nirsobj.SD;
    if isempty(SD) && isproperty(nirsobj,'subjs')
        SD = getSD(nirsobj.subjs(1));
    elseif isempty(SD) && isproperty(nirsobj,'runs')
        SD = getSD(nirsobj.runs(1));
    elseif isproperty(nirsobj, 'procInputRun') & isproperty(nirsobj.procInputRun, 'SD')
        SD = nirsobj.procInputRun.SD;
    end
elseif isproperty(nirsobj, 'procInput') & isproperty(nirsobj.procInput, 'SD')
    SD = nirsobj.procInput.SD;
    if isempty(SD) && isproperty(nirsobj,'subjs')
        SD = getSD(nirsobj.subjs(1).procInput);
    elseif isempty(SD) && isproperty(nirsobj,'runs')
        SD = getSD(nirsobj.runs(1).procInput);
    end
end
