function b = duplicate_anchors(pos, dpos, conO, conD)
%
% Usage:
%
%     b = duplicate_anchors(pos, dpos, conO, conD)
%
% Description:
%
%     Function called by positionprobe.m to checks if there
%     are 2 or more optodes anchored to the same point. Duplicate
%     anchors present a problem for positionprobe first because
%     it is incorrect. It also generates a matlab error if 
%     unchecked.
%

b=0;
for ii=1:size(pos,1)
    if all(~dpos(ii,1)) && all(~dpos(ii,2)) && all(~dpos(ii,3))
        for jj=1:length(conO(ii,:))
            if conO(ii,jj)==0
                continue;
            end
            if all(pos(ii,:) == pos(conO(ii,jj),:))
                b=1;
                return;
            end
        end
    end
end