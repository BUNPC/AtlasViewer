function [eeg_curves, err] = calcRefpts1(surf, Nz, Iz, RPA, LPA, Czi, stepsizes)

err = 0;

% Step sizes as a percentage of curve length
stepsize1 = stepsizes(1);
stepsize2 = stepsizes(2);
stepsize3 = stepsizes(3);

hwait = waitbar(0,sprintf('Calculating EEG reference points ...'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: How to get a more accurate location of Cz? Roughly speaking, Cz is the point 
% on the surface of the head that is equidistant from LPA and RPA, and from
% Nz and Iz, respectively.
% 
% The procedure used here to approximate this point is as follows:
%
% 1. Find the midpoint of LPA-Czi-RPA (Where Czi is the user's initial guess at Cz), call it Mp_LPACziRPA. 
%
% 2. Find the curve between Nz and Iz through the point Mp_LPACziRPA (in the code it's the 1st recalculation of Czi), 
%
% 3. Find the midpoint of the curve Nz-Mp_LPACziRPA-Iz. This second midpoint we take to be our Cz.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eeg_curves = init_eeg_curves1(); 
nCurves = length(fieldnames(eeg_curves));
iCurve = 1;


% Find the curve from LPA to RPA through our initial guess, Czi
[curve_pts_LPACziRPA, len_LPACziRPA] = curve_gen(LPA, RPA, Czi, surf, []);
fprintf('Initial LPA-RPA curve length: %1.1f\n', len_LPACziRPA);


display('Recalculating our guess for Cz along the curve LPA-RPA...');

% Recalculate Czi: Find the midpoint of curve from LPA to RPA 
% through our initial guess, Czi. The midpoint will be our new Czi
Czi = curve_walk(curve_pts_LPACziRPA, len_LPACziRPA/2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve and ref pts from Nz to Iz through the recalculated Czi. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[curve_pts_NzCziIz, len_NzCziIz] = curve_gen(Nz, Iz, Czi, surf, []);
[eeg_curves.NzCziIz.pos, eeg_curves.NzCziIz.len] = calcRefptsAlongCurve(curve_pts_NzCziIz, len_NzCziIz, eeg_curves.NzCziIz.labels, stepsize1, 'Nz-Czi-Iz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find Cz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Cz, len] = curve_walk(curve_pts_NzCziIz, 50*len_NzCziIz/100);
fprintf('Cz = (%1.1f, %1.1f, %1.1f) is %1.2f away from Nz\n', Cz(1), Cz(2), Cz(3), len);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve and ref pts from LPA to RPA through Cz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[curve_pts_LPACzRPA, len_LPACzRPA] = curve_gen(LPA, RPA, Cz, surf, []);
[eeg_curves.LPACzRPA.pos, eeg_curves.LPACzRPA.len] = calcRefptsAlongCurve(curve_pts_LPACzRPA, len_LPACzRPA, eeg_curves.LPACzRPA.labels, stepsize1, 'LPA-Cz-RPA');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nz-T9-Iz, Nz-T10-Iz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T9 = LPA;
T10 = RPA;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from Nz to Iz, through T9. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_NzT9Iz = curve_gen(Nz, Iz, T9, surf, []);
[~, iT9] = nearest_point(curve_pts_NzT9Iz, T9);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from Nz to T9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.NzT9.pos, eeg_curves.NzT9.len] = calcRefptsAlongCurve(curve_pts_NzT9Iz(1:iT9,:), 0, eeg_curves.NzT9.labels, 2*stepsize1, 'Nz-T9');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T9 to Iz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.T9Iz.pos, eeg_curves.T9Iz.len] = calcRefptsAlongCurve(curve_pts_NzT9Iz(iT9:end,:), 0, eeg_curves.T9Iz.labels, 2*stepsize1, 'T9-Iz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from Nz to Iz, through T10. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_NzT10Iz = curve_gen(Nz, Iz, T10, surf, []);
[~, iT10] = nearest_point(curve_pts_NzT10Iz, T10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from Nz to T10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.NzT10.pos, eeg_curves.NzT10.len] = calcRefptsAlongCurve(curve_pts_NzT10Iz(1:iT10,:), 0, eeg_curves.NzT10.labels, 2*stepsize1, 'Nz-T10');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T10 to Iz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.T10Iz.pos, eeg_curves.T10Iz.len] = calcRefptsAlongCurve(curve_pts_NzT10Iz(iT10:end,:), 0, eeg_curves.T10Iz.labels, 2*stepsize1, 'T10-Iz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NFpz-T9h-OIz, NFpz-T10h-OIz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NFpz = eeg_curves.NzCziIz.pos{1};
OIz  = eeg_curves.NzCziIz.pos{end};
T9h  = eeg_curves.LPACzRPA.pos{1};
T10h = eeg_curves.LPACzRPA.pos{end};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from NFpz to OIz, through T9h. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_NFpzT9hOIz = curve_gen(NFpz, OIz, T9h, surf, []);
[~, iT9h] = nearest_point(curve_pts_NFpzT9hOIz, T9h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from NFpz to T9h
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.NFpzT9h.pos, eeg_curves.NFpzT9h.len] = calcRefptsAlongCurve(curve_pts_NFpzT9hOIz(1:iT9h,:), 0, eeg_curves.NFpzT9h.labels, 2*stepsize1, 'NFpz-T9h');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T9h to OIz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.T9hOIz.pos, eeg_curves.T9hOIz.len] = calcRefptsAlongCurve(curve_pts_NFpzT9hOIz(iT9h:end,:), 0, eeg_curves.T9hOIz.labels, 2*stepsize1, 'T9h-OIz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from NFpz to OIz, through T10h. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_NFpzT10hOIz = curve_gen(NFpz, OIz, T10h, surf, []);
[~, iT10h] = nearest_point(curve_pts_NFpzT10hOIz, T10h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from NFpz to T10h
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.NFpzT10h.pos, eeg_curves.NFpzT10h.len] = calcRefptsAlongCurve(curve_pts_NFpzT10hOIz(1:iT10h,:), 0, eeg_curves.NFpzT10h.labels, 2*stepsize1, 'NFpz-T10h');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T10h to OIz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.T10hOIz.pos, eeg_curves.T10hOIz.len] = calcRefptsAlongCurve(curve_pts_NFpzT10hOIz(iT9h:end,:), 0, eeg_curves.T10hOIz.labels, 2*stepsize1, 'T10h-OIz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fpz-T7-Oz, Fpz-T10h-OIz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fpz = eeg_curves.NzCziIz.pos{2};
Oz  = eeg_curves.NzCziIz.pos{end-1};
T7  = eeg_curves.LPACzRPA.pos{2};
T8  = eeg_curves.LPACzRPA.pos{end-1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from Fpz to Oz, through T7. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FpzT7Oz = curve_gen(Fpz, Oz, T7, surf, []);
[~, iT7] = nearest_point(curve_pts_FpzT7Oz, T7);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from Fpz to T7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.FpzT7.pos, eeg_curves.FpzT7.len] = calcRefptsAlongCurve(curve_pts_FpzT7Oz(1:iT7,:), 0, eeg_curves.FpzT7.labels, 2*stepsize1, 'Fpz-T7');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T7 to Oz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.T7Oz.pos, eeg_curves.T7Oz.len] = calcRefptsAlongCurve(curve_pts_FpzT7Oz(iT7:end,:), 0, eeg_curves.T7Oz.labels, 2*stepsize1, 'T7-Oz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from Fpz to Oz, through T8. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FpzT8Oz = curve_gen(Fpz, Oz, T8, surf, []);
[~, iT8] = nearest_point(curve_pts_FpzT8Oz, T8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from Fpz to T8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.FpzT8.pos, eeg_curves.FpzT8.len] = calcRefptsAlongCurve(curve_pts_FpzT8Oz(1:iT8,:), 0, eeg_curves.FpzT8.labels, 2*stepsize1, 'Fpz-T8');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from T8 to Oz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.T8Oz.pos, eeg_curves.T8Oz.len] = calcRefptsAlongCurve(curve_pts_FpzT8Oz(iT8:end,:), 0, eeg_curves.T8Oz.labels, 2*stepsize1, 'T8-Oz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFp7-AFpz-AFp8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AFp7 = eeg_curves.FpzT7.pos{3};
AFp8 = eeg_curves.FpzT8.pos{3};
AFpz = eeg_curves.NzCziIz.pos{3};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from AFp7 to AFp8, through AFpz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_AFp7AFpzAFp8 = curve_gen(AFp7, AFp8, AFpz, surf, []);
[~, iAFpz] = nearest_point(curve_pts_AFp7AFpzAFp8, AFpz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AFp7 to AFpz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.AFp7AFpz.pos, eeg_curves.AFp7AFpz.len] = calcRefptsAlongCurve(curve_pts_AFp7AFpzAFp8(1:iAFpz,:), 0, eeg_curves.AFp7AFpz.labels, 2*stepsize2, 'AFp7-AFpz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AFp8 to AFpz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.AFp8AFpz.pos, eeg_curves.AFp8AFpz.len] = calcRefptsAlongCurve(curve_pts_AFp7AFpzAFp8(end:-1:iAFpz,:), 0, eeg_curves.AFp8AFpz.labels, 2*stepsize2, 'AFp8-AFpz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AF7-AFz-AF8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AF7 = eeg_curves.FpzT7.pos{4};
AF8 = eeg_curves.FpzT8.pos{4};
AFz = eeg_curves.NzCziIz.pos{4};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from AF7 to AF8, through AFz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_AF7AFzAF8 = curve_gen(AF7, AF8, AFz, surf, []);
[~, iAFz] = nearest_point(curve_pts_AF7AFzAF8, AFz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AF7 to AFz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.AF7AFz.pos, eeg_curves.AF7AFz.len] = calcRefptsAlongCurve(curve_pts_AF7AFzAF8(1:iAFz,:), 0, eeg_curves.AF7AFz.labels, stepsize2, 'AF7-AFz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AF8 to AFz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.AF8AFz.pos, eeg_curves.AF8AFz.len] = calcRefptsAlongCurve(curve_pts_AF7AFzAF8(end:-1:iAFz,:), 0, eeg_curves.AF8AFz.labels, stepsize2, 'AF8-AFz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AFF7-AFFz-AFF8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AFF7 = eeg_curves.FpzT7.pos{5};
AFF8 = eeg_curves.FpzT8.pos{5};
AFFz = eeg_curves.NzCziIz.pos{5};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from AFF7 to AFF8, through AFFz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_AFF7AFFzAFF8 = curve_gen(AFF7, AFF8, AFFz, surf, []);
[~, iAFFz] = nearest_point(curve_pts_AFF7AFFzAFF8, AFFz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AFF7 to AFFz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.AFF7AFFz.pos, eeg_curves.AFF7AFFz.len] = calcRefptsAlongCurve(curve_pts_AFF7AFFzAFF8(1:iAFFz,:), 0, eeg_curves.AFF7AFFz.labels, stepsize2, 'AFF7-AFFz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from AFF8 to AFFz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.AFF8AFFz.pos, eeg_curves.AFF8AFFz.len] = calcRefptsAlongCurve(curve_pts_AFF7AFFzAFF8(end:-1:iAFFz,:), 0, eeg_curves.AFF8AFFz.labels, stepsize2, 'AFF8-AFFz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% F7-Fz-F8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F7 = eeg_curves.FpzT7.pos{6};
F8 = eeg_curves.FpzT8.pos{6};
Fz = eeg_curves.NzCziIz.pos{6};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from F7 to F8, through Fz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_F7FzF8 = curve_gen(F7, F8, Fz, surf, []);
[~, iFz] = nearest_point(curve_pts_F7FzF8, Fz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from F7 to Fz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.F7Fz.pos, eeg_curves.F7Fz.len] = calcRefptsAlongCurve(curve_pts_F7FzF8(1:iFz,:), 0, eeg_curves.F7Fz.labels, stepsize2, 'F7-Fz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from F8 to Fz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.F8Fz.pos, eeg_curves.F8Fz.len] = calcRefptsAlongCurve(curve_pts_F7FzF8(end:-1:iFz,:), 0, eeg_curves.F8Fz.labels, stepsize2, 'F8-Fz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT7-FFCz-FFT8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FFT7 = eeg_curves.FpzT7.pos{7};
FFT8 = eeg_curves.FpzT8.pos{7};
FFCz = eeg_curves.NzCziIz.pos{7};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from FFT7 to FFT8, through FFCz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FFT7FFCzFFT8 = curve_gen(FFT7, FFT8, FFCz, surf, []);
[~, iFFCz] = nearest_point(curve_pts_FFT7FFCzFFT8, FFCz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FFT7 to FFCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.FFT7FFCz.pos, eeg_curves.FFT7FFCz.len] = calcRefptsAlongCurve(curve_pts_FFT7FFCzFFT8(1:iFFCz,:), 0, eeg_curves.FFT7FFCz.labels, stepsize2, 'FFT7-FFCz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FFT8 to FFCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.FFT8FFCz.pos, eeg_curves.FFT8FFCz.len] = calcRefptsAlongCurve(curve_pts_FFT7FFCzFFT8(end:-1:iFFCz,:), 0, eeg_curves.FFT8FFCz.labels, stepsize2, 'FFT8-FFCz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FT7-FCz-FT8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FT7 = eeg_curves.FpzT7.pos{8};
FT8 = eeg_curves.FpzT8.pos{8};
FCz = eeg_curves.NzCziIz.pos{8};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from FT7 to FT8, through FCz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FT7FCzFT8 = curve_gen(FT7, FT8, FCz, surf, []);
[~, iFCz] = nearest_point(curve_pts_FT7FCzFT8, FCz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FT7 to FCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.FT7FCz.pos, eeg_curves.FT7FCz.len] = calcRefptsAlongCurve(curve_pts_FT7FCzFT8(1:iFCz,:), 0, eeg_curves.FT7FCz.labels, stepsize2, 'FT7-FCz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FT8 to FCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.FT8FCz.pos, eeg_curves.FT8FCz.len] = calcRefptsAlongCurve(curve_pts_FT7FCzFT8(end:-1:iFCz,:), 0, eeg_curves.FT8FCz.labels, stepsize2, 'FT8-FCz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FTT7-FCCz-FTT8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FTT7 = eeg_curves.FpzT7.pos{9};
FTT8 = eeg_curves.FpzT8.pos{9};
FCCz = eeg_curves.NzCziIz.pos{9};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from FTT7 to FTT8, through FCCz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_FTT7FCCzFTT8 = curve_gen(FTT7, FTT8, FCCz, surf, []);
[~, iFCCz] = nearest_point(curve_pts_FTT7FCCzFTT8, FCCz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FTT7 to FCCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.FTT7FCCz.pos, eeg_curves.FTT7FCCz.len] = calcRefptsAlongCurve(curve_pts_FTT7FCCzFTT8(1:iFCCz,:), 0, eeg_curves.FTT7FCCz.labels, stepsize2, 'FTT7-FCCz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from FTT8 to FCCz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.FTT8FCCz.pos, eeg_curves.FTT8FCCz.len] = calcRefptsAlongCurve(curve_pts_FTT7FCCzFTT8(end:-1:iFCCz,:), 0, eeg_curves.FTT8FCCz.labels, stepsize2, 'FTT8-FCCz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TTP7-CCPz-TTP8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TTP7 = eeg_curves.T7Oz.pos{1};
TTP8 = eeg_curves.T8Oz.pos{1};
CCPz = eeg_curves.NzCziIz.pos{11};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from TTP7 to TTP8, through CCPz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_TTP7CCPzTTP8 = curve_gen(TTP7, TTP8, CCPz, surf, []);
[~, iCCPz] = nearest_point(curve_pts_TTP7CCPzTTP8, CCPz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TTP7 to CCPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.TTP7CCPz.pos, eeg_curves.TTP7CCPz.len] = calcRefptsAlongCurve(curve_pts_TTP7CCPzTTP8(1:iCCPz,:), 0, eeg_curves.TTP7CCPz.labels, stepsize2, 'TTP7-CCPz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TTP8 to CCPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.TTP8CCPz.pos, eeg_curves.TTP8CCPz.len] = calcRefptsAlongCurve(curve_pts_TTP7CCPzTTP8(end:-1:iCCPz,:), 0, eeg_curves.TTP8CCPz.labels, stepsize2, 'TTP8-CCPz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TP7-CPz-TP8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TP7 = eeg_curves.T7Oz.pos{2};
TP8 = eeg_curves.T8Oz.pos{2};
CPz = eeg_curves.NzCziIz.pos{12};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from TP7 to TP8, through CPz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_TP7CPzTP8 = curve_gen(TP7, TP8, CPz, surf, []);
[~, iCPz] = nearest_point(curve_pts_TP7CPzTP8, CPz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TP7 to CPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.TP7CPz.pos, eeg_curves.TP7CPz.len] = calcRefptsAlongCurve(curve_pts_TP7CPzTP8(1:iCPz,:), 0, eeg_curves.TP7CPz.labels, stepsize2, 'TP7-CPz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TP8 to CPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.TP8CPz.pos, eeg_curves.TP8CPz.len] = calcRefptsAlongCurve(curve_pts_TP7CPzTP8(end:-1:iCPz,:), 0, eeg_curves.TP8CPz.labels, stepsize2, 'TP8-CPz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TPP7-CPPz-TPP8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TPP7 = eeg_curves.T7Oz.pos{3};
TPP8 = eeg_curves.T8Oz.pos{3};
CPPz = eeg_curves.NzCziIz.pos{13};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from TPP7 to TPP8, through CPPz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_TPP7CPPzTPP8 = curve_gen(TPP7, TPP8, CPPz, surf, []);
[~, iCPPz] = nearest_point(curve_pts_TPP7CPPzTPP8, CPPz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TPP7 to CPPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.TPP7CPPz.pos, eeg_curves.TPP7CPPz.len] = calcRefptsAlongCurve(curve_pts_TPP7CPPzTPP8(1:iCPPz,:), 0, eeg_curves.TPP7CPPz.labels, stepsize2, 'TPP7-CPPz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from TPP8 to CPPz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.TPP8CPPz.pos, eeg_curves.TPP8CPPz.len] = calcRefptsAlongCurve(curve_pts_TPP7CPPzTPP8(end:-1:iCPPz,:), 0, eeg_curves.TPP8CPPz.labels, stepsize2, 'TPP8-CPPz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P7-Pz-P8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P7 = eeg_curves.T7Oz.pos{4};
P8 = eeg_curves.T8Oz.pos{4};
Pz = eeg_curves.NzCziIz.pos{14};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from P7 to P8, through Pz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_P7PzP8 = curve_gen(P7, P8, Pz, surf, []);
[~, iPz] = nearest_point(curve_pts_P7PzP8, Pz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from P7 to Pz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.P7Pz.pos, eeg_curves.P7Pz.len] = calcRefptsAlongCurve(curve_pts_P7PzP8(1:iPz,:), 0, eeg_curves.P7Pz.labels, stepsize2, 'P7-Pz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from P8 to Pz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.P8Pz.pos, eeg_curves.P8Pz.len] = calcRefptsAlongCurve(curve_pts_P7PzP8(end:-1:iPz,:), 0, eeg_curves.P8Pz.labels, stepsize2, 'P8-Pz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PPO7-PPOz-PPO8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PPO7 = eeg_curves.T7Oz.pos{5};
PPO8 = eeg_curves.T8Oz.pos{5};
PPOz = eeg_curves.NzCziIz.pos{15};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from PPO7 to PPO8, through PPOz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_PPO7PPOzPPO8 = curve_gen(PPO7, PPO8, PPOz, surf, []);
[~, iPPOz] = nearest_point(curve_pts_PPO7PPOzPPO8, PPOz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from PPO7 to PPOz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.PPO7PPOz.pos, eeg_curves.PPO7PPOz.len] = calcRefptsAlongCurve(curve_pts_PPO7PPOzPPO8(1:iPPOz,:), 0, eeg_curves.PPO7PPOz.labels, stepsize2, 'PPO7-PPOz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from PPO8 to PPOz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.PPO8PPOz.pos, eeg_curves.PPO8PPOz.len] = calcRefptsAlongCurve(curve_pts_PPO7PPOzPPO8(end:-1:iPPOz,:), 0, eeg_curves.PPO8PPOz.labels, stepsize2, 'PPO8-PPOz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PO7-POz-PO8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PO7 = eeg_curves.T7Oz.pos{6};
PO8 = eeg_curves.T8Oz.pos{6};
POz = eeg_curves.NzCziIz.pos{16};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from PO7 to PO8, through POz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_PO7POzPO8 = curve_gen(PO7, PO8, POz, surf, []);
[~, iPOz] = nearest_point(curve_pts_PO7POzPO8, POz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from PO7 to POz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.PO7POz.pos, eeg_curves.PO7POz.len] = calcRefptsAlongCurve(curve_pts_PO7POzPO8(1:iPOz,:), 0, eeg_curves.PO7POz.labels, stepsize2, 'PO7-POz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from PO8 to POz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.PO8POz.pos, eeg_curves.PO8POz.len] = calcRefptsAlongCurve(curve_pts_PO7POzPO8(end:-1:iPOz,:), 0, eeg_curves.PO8POz.labels, stepsize2, 'PO8-POz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POO7-POOz-POO8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
POO7 = eeg_curves.T7Oz.pos{7};
POO8 = eeg_curves.T8Oz.pos{7};
POOz = eeg_curves.NzCziIz.pos{17};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find curve from POO7 to POO8, through POOz. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curve_pts_POO7POOzPOO8 = curve_gen(POO7, POO8, POOz, surf, []);
[~, iPOOz] = nearest_point(curve_pts_POO7POOzPOO8, POOz);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from POO7 to POOz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.POO7POOz.pos, eeg_curves.POO7POOz.len] = calcRefptsAlongCurve(curve_pts_POO7POOzPOO8(1:iPOOz,:), 0, eeg_curves.POO7POOz.labels, 2*stepsize2, 'POO7-POOz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find ref pts from POO8 to POOz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eeg_curves.POO8POOz.pos, eeg_curves.POO8POOz.len] = calcRefptsAlongCurve(curve_pts_POO7POOzPOO8(end:-1:iPOOz,:), 0, eeg_curves.POO8POOz.labels, 2*stepsize2, 'POO8-POOz');
waitbar(iCurve/nCurves, hwait); iCurve=iCurve+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Last but not least, the basic head reference points 
% from which all others are derived
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eeg_curves.Nz.pos{1}  = Nz;
eeg_curves.Iz.pos{1}  = Iz;
eeg_curves.RPA.pos{1} = RPA;
eeg_curves.LPA.pos{1} = LPA;
eeg_curves.Cz.pos{1}  = Cz;

close(hwait);

