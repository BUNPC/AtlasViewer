function digpts = setDigptsOrientation(digpts, dirname)

[nz,iz,rpa,lpa,cz] = getLandmarks(digpts.refpts);

% JD removed this on 06/27/2018 because of realization that alignRefptsWithXyz
% doesn't not just rotate and translate, but changes the shape of
% the digitized points.
%
% Align dig pt axes with XYZ axes; This matters when we register atlas to
% dig points. If dig points are not very well aligned with xyz then when we
% register MRI anatomy (which is usually aligned) the newly registered MRI
% anatomy will be just as misaligned with xyz as the dig points. This will
% make standard S/I, R/A, A/P views not work very well.
%
% digpts.T_2xyz = alignRefptsWithXyz(nz, iz, rpa, lpa, cz);

[digpts.refpts.orientation, digpts.refpts.center] = getOrientation(nz, iz, rpa, lpa, cz);

digpts.orientation = digpts.refpts.orientation;
digpts.center      = digpts.refpts.center;

if exist([dirname, 'digpts2mc.txt'],'file')
    digpts.T_2mc = load([dirname, 'digpts2mc.txt'],'-ascii');
end
if exist([dirname, 'digpts2vol.txt'],'file')
    digpts.T_2vol = load([dirname, 'digpts2vol.txt'],'-ascii');
end
% T = digpts.T_2mc * digpts.T_2xyz;
% digpts.refpts.pos = xform_apply(digpts.refpts.pos, T);
% digpts.srcpos = xform_apply(digpts.srcpos, T);
% digpts.detpos = xform_apply(digpts.detpos, T);
% digpts.pcpos  = xform_apply(digpts.pcpos, T);
