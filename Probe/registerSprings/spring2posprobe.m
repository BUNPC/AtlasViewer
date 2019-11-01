function [optconn, anchor_pts] = spring2posprobe(probe, refpts, head)


optconn = [];
anchor_pts = [];

if isempty(probe)
    return;
end
if isempty(refpts)
    return;
end
refpts.labels = lower(refpts.labels);

%%% Create connectivity list
optpos = probe.optpos;
sl     = probe.sl;

%%% find maximum # of springs stemming from one optode 
for k = 1:size(optpos,1); r = find(sl(:,1)==k); m(k) = length(r); clear r; end;
m = max(m);

for ii=1:size(optpos,1)
    r = find(sl(:,1)==ii);
    neigh=[];
    for jj=1:m
        if jj<=length(r)
            neigh = [neigh sl(r(jj),2) sl(r(jj),3)];
        else
            neigh = [neigh 0 0];
        end
    end
    optconn(ii,:) = neigh;
end

%%% Resolve anchor points list
al = probe.al;
for ii=1:size(al,1)
    if ischar(al{ii,1})
        al{ii,1} = str2num(al{ii,1});
    end
    a = al{ii,1};
    k = find(strcmpi(refpts.labels, al{ii,2}));
    if ~isempty(k)
        r = refpts.pos(k,:);
    else
        r = str2num(al{ii,2});
    end
    anchor_pts(ii,:) = [a r];
end

% Make sure anchor points are on head surface, if not pull them towards the
% head surface.
anchor_pts(:,2:end) = pullPtsToSurf(anchor_pts(:,2:end), head, 'center');

