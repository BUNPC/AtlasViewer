function probe_geometry_axes_ButtonDownFcn(hObject, eventdata, handles)

% Usage:
% 
% Two ways to use mouse to select optodes:
%
% 1. If you point and click mouse on an individual optode then it'll either 
% highlight the selected optode or if it's a second optode in a source/detector 
% pair, an edge will be added or deleted depending on whether the edge already 
% exists - but no popup menu questions will be asked. 
% 
% 2. If you right-click and drag mouse to select one or more optodes 
% then popup menu questions will appear asking what action you want to
% take:  'Add/Delete Channel','Delete', or 'Cancel'
%


% Enable rubber bbox selection
pos1 = get(hObject,'currentpoint');
rbbox;
pos2 = get(hObject,'currentpoint');

probe_geometry_axes_data = get(hObject,'userdata');
optselect = probe_geometry_axes_data.optselect;
h_nodes_s = probe_geometry_axes_data.h_nodes_s;
h_nodes_d = probe_geometry_axes_data.h_nodes_d;
edges     = probe_geometry_axes_data.edges;
h_edges   = edges.handles;
axes_view = probe_geometry_axes_data.view;
fs        = probe_geometry_axes_data.fontsize;
fc_s      = probe_geometry_axes_data.fontcolor_s;
fc_d      = probe_geometry_axes_data.fontcolor_d;
threshold = probe_geometry_axes_data.threshold;

% Set threshold level
l = 1;

optpos_det = getOptPosFromAxes(h_nodes_d);
optpos_src = getOptPosFromAxes(h_nodes_s);
optpos     = [optpos_src; optpos_det];
if(isempty(optpos))
    return;
end
p = get_pt_from_buttondown([pos1;pos2], optpos, axes_view);

d1 = 0;
d2 = 0;
src=[];
det=[];
if size(p,1)>1
    [isrc,idet] = getSelectedOptodes(p, optpos_src, optpos_det, axes_view);
else
    [p1,isrc,d1] = nearest_point(optpos_src,p);
    [p2,idet,d2] = nearest_point(optpos_det,p);
end

actions = {'Add/Delete Channel','Delete','Cancel'};
action = '';

% Check if multiple optiodes were selected
if size(p,1)>1
    
    optselect.src(isrc)=1;
    set(h_nodes_s(isrc),'fontweight','bold','fontsize',fs(2),'color',fc_s(2,:));
    
    optselect.det(idet)=1;
    set(h_nodes_d(idet),'fontweight','bold','fontsize',fs(2),'color',fc_d(2,:));
    
    src = optpos_src(isrc,:);
    det = optpos_det(idet,:);
    if length(isrc)==1 & length(idet)==1
        action = actions{menu('What action do you want to take with the selected optodes?',actions)};
    elseif ~isempty(isrc) | ~isempty(idet)
        action = actions{menu('Are you sure you want to delete the selected optodes?',actions{2:3})+1};
    end
    
    % Clean up
    optselect.src(:) = 0;
    optselect.det(:) = 0;
    set(h_nodes_s,'fontweight','bold','fontsize',fs(1),'color',fc_s(1,:));
    set(h_nodes_d,'fontweight','bold','fontsize',fs(1),'color',fc_d(1,:));
    
    % Check whether a source was selected
elseif isrc>0  &&  d1<threshold(3) && (idet==0 || d1<d2)
    
    if(optselect.src(isrc)==1)
        optselect.src(isrc)=0;
        set(h_nodes_s(isrc),'fontweight','bold','fontsize',fs(1),'color',fc_s(1,:));
    elseif all(~optselect.src)
        optselect.src(isrc)=1;
        set(h_nodes_s(isrc),'fontweight','bold','fontsize',fs(2),'color',fc_s(2,:));
        src = p1;
        
        % Optode selected is a src. Check if there's a det
        % selected.
        idet = find(optselect.det==1);
        if(~isempty(idet))
            det = optpos_det(idet,:);
            action = actions{1};
        end
    end
    
    % Check whether a detector was selected
elseif idet>0  &&  d2<threshold(3) && (isrc==0 || d2<d1)
    
    if(optselect.det(idet)==1)
        optselect.det(idet)=0;
        set(h_nodes_d(idet),'fontweight','bold','fontsize',fs(1),'color',fc_d(1,:));
    elseif all(~optselect.det)
        optselect.det(idet)=1;
        set(h_nodes_d(idet),'fontweight','bold','fontsize',fs(2),'color',fc_d(2,:));
        det = p2;
        
        % Optode selected is a det. Check if there's a src
        % selected.
        
        isrc = find(optselect.src==1);
        if(~isempty(isrc))
            src = optpos_src(isrc,:);
            action = actions{1};
        end
    end
    
end


ml = getMeasListFromAxes(optpos_src, optpos_det, h_edges);

% Perform the action user requested
switch(action)
    
    case 'Add/Delete Channel'
        
        % One source and one detector were selected, draw an edge between them if
        % an edge does not exist between them. If it does, then delete it.
        if(~isempty(ml))
            i=find(ml(:,1)==isrc & ml(:,2)==idet);
        else
            i=[];
        end
        
        % Check whether the measurement pair already exists
        % in ml
        if(isempty(i))
            h_edges(end+1) = line([src(:,1) det(:,1)],[src(:,2) det(:,2)],[src(:,3) det(:,3)],...
                'color',edges.color,'linewidth',edges.thickness,...
                'hittest','off','ButtonDownFcn','probe_geometry_axes_ButtonDownFcn');
            ml(end+1,:) = [isrc idet];
            
            % We want the optodes to be drawn over the new edge
            % so redraw the two the are involved in the measurement
            % pair
            h_nodes_s(isrc) = redraw_text(h_nodes_s(isrc));
            h_nodes_d(idet) = redraw_text(h_nodes_d(idet));
        else
            delete(h_edges(i));
            h_edges(i)=[];
            ml(i,:)=[];
        end
        
        % Update SD Measuremnt List
        i = sd_data_SetMeasList(ml);
        
        % reset node all node selections zero
        optselect.src(:) = 0;
        set(h_nodes_s(:),'fontweight','bold','fontsize',fs(1),'color',fc_s(1,:));
        
        optselect.det(:) = 0;
        set(h_nodes_d(:),'fontweight','bold','fontsize',fs(1),'color',fc_d(1,:));
        
    case 'Delete'
        
        % Get ALL meas list edges associated with selected optodes
        i = [];
        kk = 1;
        for ii=1:length(isrc)
            i = [i; find(ml(:,1)==isrc(ii))];
        end
        for ii=1:length(idet)
            i = [i; find(ml(:,2)==idet(ii))];
        end
        i = sort(unique(i));
        
        probe_geometry_axes_DeleteOpt(handles, isrc, idet);
        
        % Delete the optodes from axes
        h_nodes_s(isrc) = [];
        h_nodes_d(idet) = [];
        optselect.src(isrc) = [];
        optselect.det(idet) = [];
        
        % Deselect all
        optselect.src(:) = 0;
        optselect.det(:) = 0;
        
        % Update SD Measuremnt List
        h_edges(i)=[];
        
    case 'Cancel'
        
        ;
        
end


% Save the changes the user made
probe_geometry_axes_data.optselect=optselect;
probe_geometry_axes_data.edges.handles=h_edges;
probe_geometry_axes_data.h_nodes_s = h_nodes_s;
probe_geometry_axes_data.h_nodes_d = h_nodes_d;
set(hObject,'userdata',probe_geometry_axes_data);





% ------------------------------------------------------------
function [isrc,idet] = getSelectedOptodes(bbox, optpos_src, optpos_det, axes_view)

isrc = [];
idet = [];
jj = 1;
kk = 1;

% Determine which axes are in view
switch lower(axes_view)
    case {'xy', 'x-y'}
        r = [1,2];
    case {'xz', 'x-z'}
        r = [1,3];
    case {'yz', 'y-z'}
        r = [2,3];
end

x1 = min(bbox(:,r(1)));
x2 = max(bbox(:,r(1)));
y1 = min(bbox(:,r(2)));
y2 = max(bbox(:,r(2)));


% Determine which optodes lie within the bounding box
for ii=1:size(optpos_src)
    if ((optpos_src(ii,r(1)) >= x1) & (optpos_src(ii,r(1)) <= x2)) & ...
       ((optpos_src(ii,r(2)) >= y1) & (optpos_src(ii,r(2)) <= y2))
        isrc(jj) = ii;
        jj=jj+1;
    end
end

for ii=1:size(optpos_det)
    if ((optpos_det(ii,r(1)) >= x1) & (optpos_det(ii,r(1)) <= x2)) & ...
       ((optpos_det(ii,r(2)) >= y1) & (optpos_det(ii,r(2)) <= y2))
        idet(kk) = ii;
        kk=kk+1;
    end
end

