function b = equal(x1, x2, err)

b=[];
if ~all(size(x1)==size(x2))
    return;
end

if ~exist('err','var')
    err=1e-5;
end

if all(abs(x1-x2)<err)
    b=true;
else
    b=false;
end

