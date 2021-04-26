% Usage:
%
%     data = SDgui_AtlasViewerGUI(action)
%
% Description:
%
%     Function allows SDgui to interface with AtlasViewerGUI while still being a fully
%     standalone tool (ie without any dependencies on AtlasViewerGUI). It is the only
%     place in SDgui with access to the global variable atlasViewer.
%
function SDgui_AtlasViewerGUI(action, SDo)
global atlasViewer
global SD

if isempty(atlasViewer)
    return;
end

if nargin==2
    SD = SDo;
end

switch(lower(action))
    case {'close','delete'}
        
        atlasViewer.probe.handles.hSDgui = [];
        probe = atlasViewer.probe;
        set(probe.handles.checkboxHideProbe,'enable','off');
        set(probe.handles.checkboxHideSprings,'enable','off');
        set(probe.handles.checkboxHideDummyOpts,'enable','off');
        set(probe.handles.menuItemProjectOptodesToCortex, 'enable','off');
        set(probe.handles.menuItemProjectChannelsToCortex, 'enable','off');
        
    case {'update'}
        
        probe = convertSD2probe(SD);
        atlasViewer.probe = atlasViewer.probe.copy(atlasViewer.probe, probe);
end
        
