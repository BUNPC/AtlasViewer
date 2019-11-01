function refpts = xform_apply_Refpts(refpts, T)

refpts.pos = xform_apply(refpts.pos, T);
refpts.cortexProjection.pos = xform_apply(refpts.cortexProjection.pos, T);
refpts.center = xform_apply(refpts.center, T);

curves = fieldnames(refpts.eeg_system.curves);
for ii=1:length(curves)
    eval(sprintf('curve = refpts.eeg_system.curves.%s;', curves{ii}));
    for jj=1:length(curve.pos)
        curve.pos{jj} = xform_apply(curve.pos{jj}, T);
    end
    eval(sprintf('refpts.eeg_system.curves.%s.pos = curve.pos;', curves{ii}));    
end
refpts = calcRefptsCircumf(refpts);
