function axesv = setLighting(axesv, obj)

haxes = axesv(1).handles.axesSurfDisplay;

if obj.isempty(obj)
    return;
end

%%% Position; set up light in all 8 corners so that no part 
%%% of the head is in the dark
switch(obj.name)
    case 'axesv'
        lims = get(haxes,{'xlim','ylim','zlim'});
        xmin=lims{1}(1);
        xmax=lims{1}(2);
        ymin=lims{2}(1);
        ymax=lims{2}(2);
        zmin=lims{3}(1);
        zmax=lims{3}(2);
        position = [...
            xmin ymin zmin; ...
            xmin ymin zmax; ...
            xmin ymax zmin; ...
            xmin ymax zmax; ...
            xmax ymin zmin; ...
            xmax ymin zmax; ...
            xmax ymax zmin; ...
            xmax ymax zmax; ...
            ];
    case {'headsurf','pialsurf','fwmodel','labelssurf'}
        position = gen_bbox(obj.mesh.vertices, 50);
    case 'headvol'
        position = gen_bbox(obj.img, 50);
end


%%% Color
%{
cmin=.3;
c = cmin + cmin*rand(8,1);
%}
c = ones(8,3)*.4;

%%% Lights on/off, local/infinite
%%% Create the cameras
for ii=1:size(position,1)
    if axesv(1).lighting(ii,1)==1
        visible='on';
        eval(sprintf('set(axesv(1).handles.menuItemLight%s,''checked'',''on'');', num2str(ii)));
    elseif axesv(1).lighting(ii,1)==0
        visible='off';
        eval(sprintf('set(axesv(1).handles.menuItemLight%s,''checked'',''off'');', num2str(ii)));
    end
    if axesv(1).lighting(ii,2)==1
        style='local';
    elseif axesv(1).lighting(ii,2)==0
        style='infinite';
    end

    if ~isempty(axesv(1).handles.lighting)
        if ishandle(axesv(1).handles.lighting(ii))
            delete(axesv(1).handles.lighting(ii));
        end
    end
    
    hl(ii) = camlight;
    set(hl(ii),'position',position(ii,:),'color',[c(ii) c(ii) c(ii)],...
       'visible',visible,'style',style);
end
axesv(1).handles.lighting = hl;

