function probe = setProbeDisplay(probe, headsurf, method, iCh)

hProjectionRays = probe.handles.hProjectionRays;
hSprings        = probe.handles.hSprings;
hMeasList       = probe.handles.hMeasList;
noptorig        = probe.noptorig;
sl              = probe.sl;
hOidx           = probe.hOptodesIdx;
nopt            = size(probe.handles.hOptodes,1);
nsrc            = probe.nsrc;
optViewMode     = probe.optViewMode;

% Parse arguments
if ~exist('method','var') || isempty(method)
    if ~ishandles(hSprings)
        method = 'digpts';
    else
        method = 'springs';
    end
end
if ~exist('headsurf','var') || isempty(headsurf)
    headsurf=[];
end
if ~exist('iCh','var')
    iCh=[];
end

if strcmp(optViewMode,'numbers')
    set(probe.handles.hOptodesCircles,'visible','off');
    hOptodes      = probe.handles.hOptodes;
elseif strcmp(optViewMode,'circles')
    set(probe.handles.hOptodes,'visible','off');
    hOptodes      = probe.handles.hOptodesCircles;
end

if isempty(probe.handles.hOptodes) || isempty(probe.optpos)
    return;
end

iAct   = hOidx;
iInAct = ~(iAct-1)+1;

if ishandles(hMeasList)
    set(hMeasList,'color','y','linewidth',2);
    if iCh~=0
        set(hMeasList(iCh,1),'color','g','linewidth',3);
    end
end

% Enable/disable gui objects
probe = updateProbeGuiControls(probe,headsurf,method, 'silent');

probe = setOptodeNumbering(probe);

% display/undisplay probe related objects
if strcmp(method,'digpts')
   if probe.hideProbe==1
      set(hOptodes,'visible','off');
      if ishandles(hProjectionRays)
          set(hProjectionRays,'visible','off');
      end
      if ishandles(hMeasList)
          set(hMeasList,'visible','off');
      end
   else
      set(hOptodes(:,iAct),'visible','on');
      set(hOptodes(:,iInAct),'visible','off');
      if ishandles(hProjectionRays)
          set(hProjectionRays,'visible','on');
      end
      if ishandles(hMeasList) & probe.hideMeasList
          set(hMeasList,'visible','off');
      elseif ishandles(hMeasList)
          set(hMeasList,'visible','on');
      end
   end
elseif strcmp(method,'springs')
   iDummy = noptorig+1 : nopt;
   iSprDum=[];
   for i=1:length(iDummy)
      iSprDum = [iSprDum; find(sl(:,1)==iDummy(i) | sl(:,2)==iDummy(i))]; 
   end
   iSprDum = sort(iSprDum);
   
   if probe.hideProbe==1
      set(hSprings,'visible','off');
      set(hOptodes(:,iAct),'visible','off');
      if ishandles(hProjectionRays)
         set(hProjectionRays,'visible','off');
      end
      if ishandles(hMeasList)
          set(hMeasList,'visible','off');
      end      
   elseif probe.hideProbe==0
      if probe.hideSprings==0 && probe.hideDummyOpts==0
         set(hOptodes(:,iAct),'visible','on');
         set(hOptodes(:,iInAct),'visible','off');
         set(hOptodes(iDummy,iAct),'visible','on');
         set(hOptodes(iDummy,iInAct),'visible','off');
         if ishandles(hProjectionRays)
            set(hProjectionRays,'visible','on');
         end
         if ishandles(hMeasList) & probe.hideMeasList
             set(hMeasList,'visible','off');
             set(hSprings,'visible','on');
         elseif ishandles(hMeasList)
             set(hMeasList,'visible','on');
             set(hSprings,'visible','off');
         elseif ~ishandles(hMeasList)
             set(hSprings,'visible','on');
         end
      elseif probe.hideSprings==0 && probe.hideDummyOpts==1
         if ishandles(hProjectionRays)
            set(hProjectionRays,'visible','on');
         end
         set(hOptodes(:,iAct),'visible','on');
         set(hOptodes(:,iInAct),'visible','off');
         set(hOptodes(iDummy,iAct),'visible','off');
         if ishandles(hMeasList) & probe.hideMeasList
             set(hMeasList,'visible','off');
             set(hSprings,'visible','on');
         elseif ishandles(hMeasList)
             set(hMeasList,'visible','on');
             set(hSprings,'visible','off');
         elseif ~ishandles(hMeasList)
             set(hSprings,'visible','on');
         end
         set(hSprings(iSprDum),'visible','off');      
      elseif probe.hideSprings==1 && probe.hideDummyOpts==0
         set(hOptodes(:,iAct),'visible','on');
         set(hOptodes(:,iInAct),'visible','off');
         if ishandles(hProjectionRays)
             set(hProjectionRays,'visible','on');
         end
         set(hSprings,'visible','off');
         set(hOptodes(iDummy,iAct),'visible','on');
         set(hOptodes(iDummy,iInAct),'visible','off');
         if ishandles(hMeasList) & probe.hideMeasList
             set(hMeasList,'visible','off');
         elseif ishandles(hMeasList)
             set(hMeasList,'visible','on');
         end
      elseif probe.hideSprings==1 && probe.hideDummyOpts==1
         set(hOptodes(:,iAct),'visible','on');
         set(hOptodes(:,iInAct),'visible','off');
         if ishandles(hProjectionRays)
             set(hProjectionRays,'visible','on');
         end
         set(hSprings,'visible','off');
         set(hOptodes(iDummy,:),'visible','off');
         if ishandles(hMeasList) & probe.hideMeasList
             set(hMeasList,'visible','off');
         elseif ishandles(hMeasList)
             set(hMeasList,'visible','on');
         end
      end
   end
end

