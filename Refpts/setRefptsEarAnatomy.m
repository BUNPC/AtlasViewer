function refpts = setRefptsEarAnatomy(refpts, ear_part)

if exist('ear_part','var')
    refpts.eeg_system.ear_refpts_anatomy = ear_part;
    if strcmpi(refpts.eeg_system.ear_refpts_anatomy, 'preauricular')
        refpts.eeg_system.curves = init_eeg_curves1();
        refpts.calcRefpts = @calcRefpts1;
    else
        refpts.eeg_system.curves = init_eeg_curves0();
        refpts.calcRefpts = @calcRefpts0;
    end
    refpts.eeg_system.labels = extract_eeg_labels(refpts.eeg_system.curves);
else
    if strcmpi(refpts.eeg_system.ear_refpts_anatomy, 'preauricular')
        refpts.calcRefpts = @calcRefpts1;
    else
        refpts.calcRefpts = @calcRefpts0;
    end
end

