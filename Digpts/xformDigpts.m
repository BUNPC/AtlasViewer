function digpts = xformDigpts(digpts, T)

if ~exist('T','var') || isempty(T)
    T = digpts.T_2vol;
end

digpts.refpts.pos = xform_apply(digpts.refpts.pos, T);
digpts.pcpos      = xform_apply(digpts.pcpos, T);
digpts.srcpos     = xform_apply(digpts.srcpos, T);
digpts.detpos     = xform_apply(digpts.detpos, T);
digpts.center     = digpts.refpts.center;
