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
        if(isfield(SD,'SrcGrommetType'))
            probe.srcgrommettype = SD.SrcGrommetType;
        end
        if(isfield(SD,'DetGrommetType'))
            probe.detgrommettype = SD.DetGrommetType;
        end
        if(isfield(SD,'DummyGrommetType'))
            probe.dummygrommettype = SD.DummyGrommetType;
        end
        if(isfield(SD,'SrcGrommetRot'))
            probe.SrcGrommetRot = SD.SrcGrommetRot;
        end
        if(isfield(SD,'DetGrommetRot'))
            probe.DetGrommetRot = SD.DetGrommetRot;
        end
        if(isfield(SD,'DummyGrommetRot'))
            probe.DummyGrommetRot = SD.DummyGrommetRot;
        end
        if(isfield(SD,'DummyPos'))
            probe.registration.dummypos = SD.DummyPos;
        end
        if(isfield(SD,'nSrcs'))
            probe.nsrc = SD.nSrcs;
        end
        if(isfield(SD,'nDets'))
            probe.ndet = SD.nDets;
        end
        if(isfield(SD,'MeasList'))
            probe.ml = SD.MeasList;
        end
        if(isfield(SD,'SpringList'))
            probe.registration.sl = SD.SpringList;
        end
        if(isfield(SD,'AnchorList'))
            probe.registration.al = SD.AnchorList;
        end
        probe.optpos = [probe.srcpos; probe.detpos; probe.registration.dummypos];
        probe.noptorig = size([probe.srcpos; probe.detpos],1);
        
        atlasViewer.probe = probe;
        
end
