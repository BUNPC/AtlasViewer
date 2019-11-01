function b=isregistered(refpts,digpts,EPS)

b = false;

% Args error checking
if refpts.isempty(refpts)
    return;
end
if digpts.refpts.isempty(digpts.refpts)
    return;
end
if ~exist('EPS','var')
    EPS=8;  % mm
end

p1=[];
p2=[];

[nz1,iz1,rpa1,lpa1,cz1] = getLandmarks(refpts);
[nz2,iz2,rpa2,lpa2,cz2] = getLandmarks(digpts.refpts);

if isempty(nz1) | isempty(iz1) | isempty(rpa1) | isempty(lpa1) | isempty(cz1)
    return;
end
if isempty(nz2) | isempty(iz2) | isempty(rpa2) | isempty(lpa2) | isempty(cz2)
    return;
end

p1 = [nz1; iz1; rpa1; lpa1; cz1];
p2 = [nz2; iz2; rpa2; lpa2; cz2];

d = dist3(p1,p2);
if all(d<EPS)
    b = true;
end

