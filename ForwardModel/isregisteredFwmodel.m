function b = isregisteredFwmodel(fwmodel, headvol)

EPS = 1e-5;

b1 = false;
b2 = false;

if all(abs(fwmodel.headvol.T_2digpts(:) - headvol.T_2digpts(:)) < EPS)
    b1 = true;
end
if ~isempty(fwmodel.headvol.img)
    b2 = true;
end

b = b1 & b2;

