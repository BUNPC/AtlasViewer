function xi = meanweighted(x, r, ri)

xi = [];

if isempty(x)
    return;    
end
if isempty(r)
    return;    
end
if isempty(ri)
    return;    
end

d = [];      
W = [];
X = [];
N = length(x);
for j=1:N
    d(j) = dist3(r(j,:),ri);
    if d(j)==0
        xi = x(j);
        return;
    end
    W(j) = 1/d(j);
    X(j) = x(j)*W(j);
end

if sum(W)~=0
    xi = sum(X)/sum(W);
else
    xi = 0;
end

