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
function SDgui_AtlasViewerGUI(action)
global atlasViewer
global SD

if isempty(atlasViewer)
    return;
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
        
        probe = atlasViewer.probe;
        
        if(isfield(SD,'Lambda'))
            probe.lambda = SD.Lambda;
        end
        if(isfield(SD,'SrcPos'))
            probe.srcpos = SD.SrcPos;
        end
        if(isfield(SD,'DetPos'))
            probe.detpos = SD.DetPos;
        end
        if(isfield(SD,'GrommetType'))
            probe.grommettype = SD.GrommetType;
        end
        if(isfield(SD,'DummyPos'))
            probe.dummypos = SD.DummyPos;
        end
        if(isfield(SD,'nSrcs'))
            probe.nsrc = SD.nSrcs;
        end
        if(isfield(SD,'nDets'))
            probe.ndet = SD.nDets;
        end
        if(isfield(SD,'nDummys'))
            probe.ndummy = SD.nDummys;
        end
        if(isfield(SD,'MeasList'))
            probe.ml = SD.MeasList;
        end
        if(isfield(SD,'SpringList'))
            probe.sl = SD.SpringList;
        end
        if(isfield(SD,'AnchorList'))
            probe.al = SD.AnchorList;
        end
        probe.optpos = [probe.srcpos; probe.detpos; probe.dummypos];
        probe.noptorig = size([probe.srcpos; probe.detpos],1);
        
        atlasViewer.probe = probe;
        
end
