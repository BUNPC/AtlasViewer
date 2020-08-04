function p = get_pt_from_buttondown(pos,optpos,axes_view)

p = [];
EPS = 1;

for ii=1:size(pos,1)/2
    switch lower(axes_view)
        case {'xy', 'x-y'}
            if ii>1 & (pos(ii*2,1)-p(ii-1,1) < EPS) & (pos(ii*2,2)-p(ii-1,2) < EPS)
                continue;
            end
            p(ii,1) = pos(ii*2,1);
            p(ii,2) = pos(ii*2,2);
            p(ii,3) = optpos(1,3);
        case {'xz', 'x-z'}
            if ii>1 & (pos(ii*2,1)-p(ii-1,1) < EPS) & (pos(ii*2,3)-p(ii-1,3) < EPS)
                continue;
            end
            p(ii,1) = pos(ii*2,1);
            p(ii,2) = optpos(1,2);
            p(ii,3) = pos(ii*2,3);
        case {'yz', 'y-z'}
            if ii>1 & (pos(ii*2,2)-p(ii-1,2) < EPS) & (pos(ii*2,3)-p(ii-1,3) < EPS)
                continue;
            end
            p(ii,1) = optpos(1,1);
            p(ii,2) = pos(ii*2,2);
            p(ii,3) = pos(ii*2,3);
    end
end