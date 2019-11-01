function [refpts, pos] = updateRefpts(refpts, headsurf, labels, hAxes)

pos=[];
pos0 = headsurf.currentPt;
if size(pos0,1)<length(labels)    
    return;
end

% Get real coordinates of pos0 by unflipping left-right if they were flipped. 
if leftRightFlipped(headsurf)
    axes_order=[2 1 3];
else
    axes_order=[1 2 3];
end
pos = [pos0(:,axes_order(1)), pos0(:,axes_order(2)), pos0(:,axes_order(3))];

if ~exist('hAxes','var')
    hAxes=[];
else
    axes(hAxes);
    hold on;
end

for ii=1:length(labels)
    
    % Search for the reference point label being selected in the existing 
    % list 
    labelfound=false;
    for jj=1:length(refpts.labels)
        if strcmpi(labels{ii}, refpts.labels{jj})
            labelfound=true;
            break;
        end
    end
        
    % Search for the reference point position being selected in the existing
    % list 
    posfound=false;
    for kk=1:size(refpts.pos,1)
        % if all(pos(ii,:) == refpts.pos(kk,:))
        if dist3(pos(ii,:), refpts.pos(kk,:))<1
            posfound=true;
            break;
        end
    end
    
    % Search for the reference point handle being selected in the existing 
    % list 
    handlefound=false;
    idx=[];
    if labelfound
        idx = jj;
    elseif posfound
        idx = kk;
    end
    if ~isempty(idx)
        if ishandle(refpts.handles.selected(idx))
            handlefound=true;
        end
    end
    
    % Decide which reference point to add, delete or edit based on their
    % existence in the current refpts list
    refpts = editSelectedPt(refpts, labels{ii}, pos(ii,:), labelfound, posfound, handlefound, jj, kk, headsurf);

end

updateSelectBttns(refpts);




% -------------------------------------------------------------------------
function refpts = editSelectedPt(refpts, label, pos, labelfound, posfound, handlefound, jj, kk, headsurf)

if labelfound & posfound & handlefound
    % if label and position areassociated with the same point, delete point
    if jj==kk
        refpts.pos(jj,:) = [];
        refpts.labels(jj) = [];
        if ishandle(refpts.handles.selected(jj))
            delete(refpts.handles.selected(jj))
        end
        refpts.handles.selected(jj) = [];
    else
        % Point with selcted label is reassigned position and point
        % handle of point with selected position
        if ishandle(refpts.handles.selected(jj))
            delete(refpts.handles.selected(jj))
        end
        refpts.handles.selected(jj) = refpts.handles.selected(kk);
        refpts.pos(jj,:) = refpts.pos(kk,:);
        
        % Delete ref point from refpts list with selected position
        refpts.labels(kk) = [];
        refpts.pos(kk,:) = [];
        refpts.handles.selected(kk) = [];
    end
elseif ~labelfound & posfound & handlefound
    refpts.handles.selected(end+1) = refpts.handles.selected(kk);
    refpts.pos(end+1,:) = refpts.pos(kk,:);
    refpts.labels{end+1} = label;
    
    % Delete ref point from refpts list with selected position
    refpts.labels(kk) = [];
    refpts.pos(kk,:) = [];
    refpts.handles.selected(kk) = [];
elseif labelfound & ~posfound & handlefound
    % change it's position to the new one selected
    refpts.pos(jj,:) = pos;
    refpts.handles.selected(jj) = markSelectedPt(refpts.handles.selected(jj), pos, headsurf.orientation);
elseif ~labelfound & ~posfound
    % If neither label nor position exist in the reference point list, then create new entry
    refpts.pos(end+1,:) = pos;
    refpts.labels{end+1} = label;
    refpts.handles.selected(end+1) = markSelectedPt([], pos, headsurf.orientation);
elseif labelfound & posfound & ~handlefound
    % If label and position exist but not handle, then create new handle for existing entry
    if jj==kk
        refpts.handles.selected(jj) = markSelectedPt([], pos, headsurf.orientation);
    end
elseif labelfound & ~posfound & ~handlefound
    % change it's position to the new one selected
    refpts.pos(jj,:) = pos;
    refpts.handles.selected(jj) = markSelectedPt(refpts.handles.selected(jj), pos, headsurf.orientation);
end




% -------------------------------------------------------------------------
function hp = markSelectedPt(hp, pos_new, orientation)

% Display function needs to know how to order axes so left-right sides 
% appear correctly
if leftRightFlipped(orientation)
    axes_order=[2 1 3];
else
    axes_order=[1 2 3];
end
p = [pos_new(axes_order(1)), pos_new(axes_order(2)), pos_new(axes_order(3))];

if ishandles(hp)
    set(hp(1), 'xdata',p(1), 'ydata',p(2), 'zdata',p(3));
else
    hp = plot3(p(1), p(2), p(3), '.m','markersize',30);
end


