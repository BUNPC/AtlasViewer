function probe = position_flat_probe(probe, refpts, headvol)

optpos = probe.optpos;
al = probe.registration.al;

if isempty(probe.registration.al)
    return;
end
if isempty(probe.registration.sl)
    return;
end
if isempty(probe.optpos)
    return;
end

refpts.eeg_system.selected = '10-5';
refpts = set_eeg_active_pts(refpts, [], false);

%%% Resolve anchor points list
for ii=1:size(al,1)
    if ischar(al{ii,1})
        al{ii,1} = str2num(al{ii,1});
    end
    a = al{ii,1};
    k = find(strcmpi(refpts.labels,lower(al{ii,2})));
    if ~isempty(k)
        r = refpts.pos(k,:);
    else
        r = str2num(al{ii,2});
    end
    anchor_pts(ii,:) = [a r];
end

% Make sure anchor points are on head surface, if not pull them towards the
% head surface.
anchor_pts(:,2:end) = pullPtsToSurf(anchor_pts(:,2:end), headvol, 'center');

%%%% TRANSFORM FLAT OPTODES TO HEAD
if all(anchor_pts(:,1) <= size(optpos,1))
	p1 = optpos(anchor_pts(:,1),:);
	p2 = anchor_pts(:,2:4);
	T = gen_xform_from_pts(p1,p2);
	if isempty(T)
		return;
	end
	optpos = (T*[optpos';ones(1,size(optpos,1))])';
	optpos(:,4) = [];
end

probe.optpos = optpos;

