function digpts = xformDigpts(digpts, refpts)

if ~exist('refpts','var') || isempty(refpts)
    refpts = [];
end
[rp_atlas, rp_subj] = findCorrespondingRefpts(refpts, digpts);
T = gen_xform_from_pts(rp_subj, rp_atlas);

digpts.refpts.pos = xform_apply(digpts.refpts.pos, T);
digpts.pcpos      = xform_apply(digpts.pcpos, T);
digpts.srcpos     = xform_apply(digpts.srcpos, T);
digpts.detpos     = xform_apply(digpts.detpos, T);
digpts.center     = digpts.refpts.center;

digpts.T_2vol = T;