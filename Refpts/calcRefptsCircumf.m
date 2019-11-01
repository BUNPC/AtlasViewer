function refpts = calcRefptsCircumf(refpts)

curves = refpts.eeg_system.curves;

Nz  = curves.Nz.pos{1};
Iz  = curves.Iz.pos{1};
LPA = curves.LPA.pos{1};
RPA = curves.RPA.pos{1};

Fpz = curves.NzCziIz.pos{2};
Oz  = curves.NzCziIz.pos{end-1};
T7  = curves.LPACzRPA.pos{2};
T8  = curves.LPACzRPA.pos{end-1};

% Circumference: len(FpzT7) + len(T7Oz) + len(FpzT8) + len(T8Oz)  
[~, len1] = curve_walk([Fpz; curves.FpzT7.pos(2:end); T7]);
[~, len2] = curve_walk([T7 ; curves.T7Oz.pos(1:end-1);  Oz]);
[~, len3] = curve_walk([Fpz; curves.FpzT8.pos(2:end); T8]);
[~, len4] = curve_walk([T8 ; curves.T8Oz.pos(1:end-1);  Oz]);
circumference = len1+len2+len3+len4;

% Length of curve NzCziIz
[~, len_sagittal] = curve_walk([Nz; curves.NzCziIz.pos; Iz]);

% Length of curve LPACzRPA
[~, len_coronal] = curve_walk([LPA; curves.LPACzRPA.pos; RPA]);


refpts.eeg_system.lengths.circumference = circumference;
refpts.eeg_system.lengths.NzCzIz = len_sagittal;
refpts.eeg_system.lengths.LPACzRPA = len_coronal;

set(refpts.handles.editCircumference, 'string',sprintf('%0.1f',circumference*refpts.scaling));
set(refpts.handles.editSagittal, 'string',sprintf('%0.1f',len_sagittal*refpts.scaling));
set(refpts.handles.editCoronal, 'string',sprintf('%0.1f',len_coronal*refpts.scaling));

