function digpts = calcDigptsFromHeadsize(digpts, refpts)

xo = [70, 70, 70];
x = fminsearch( @(x) ellipse_1020_costfun(x,digpts.headsize),xo);

a = x(1); % LPA to RPA axis
b = x(2); % Nz to Iz axis
c = x(3); % Cz axis

r10p = 18*3.14159/180;

Cz  = [0,            0,            c];
LPA = [-a*cos(r10p), 0,           -c*sin(r10p)];
RPA = [a*cos(r10p),  0,           -c*sin(r10p)];
Nz  = [0,            b*cos(r10p), -c*sin(r10p)];
Iz  = [0,           -b*cos(r10p), -c*sin(r10p)];

digpts.refpts.pos    = [Nz; Iz; LPA; RPA; Cz];
digpts.refpts.labels = {'nz', 'iz', 'lpa', 'rpa', 'cz'};
saveDigpts(digpts, 'overwrite');
digpts = getDigpts(digpts, pwd);

% Generate transformation from digitized point space to head volume
[rp_atlas, rp_subj] = findCorrespondingRefpts(refpts, digpts);
digpts.T_2vol = inv(gen_xform_from_pts(rp_atlas, rp_subj));

