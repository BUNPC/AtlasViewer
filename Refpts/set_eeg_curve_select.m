function refpts = set_eeg_curve_select(refpts)

curves = fieldnames(refpts.eeg_system.curves);
for jj=1:length(curves)
    eval(sprintf('refpts.eeg_system.curves.%s.selected = 1;', curves{jj}));
end
