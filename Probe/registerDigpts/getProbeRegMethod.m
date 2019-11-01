function method = getProbeRegMethod()
global probeRegMethod

method='';

probeRegMethod = struct('anchor',1,'canonical',0,'apply',0);

hfig = figure('numbertitle','off','menubar','none','name','Registration Method','units','pixels','position',[200 500 250 150]); 
hpanel = uipanel('parent',hfig,'units','normalized','position',[.1 .3 .75 .5]); 
har = uicontrol('parent',hpanel,'style','radiobutton','tag','radiobuttonAnchor',...
                'string','Anchor-based Registration',...
                'units','normalized','position',[.1 .65 .8 .2],'value',1,...
                'callback','radiobuttonAnchor_Callback(get(gcbo,''parent''))');
hcr = uicontrol('parent',hpanel,'style','radiobutton','tag','radiobuttonCanonical',...
                'string','Canonical Registration',...
                'units','normalized','position',[.1 .35 .8 .2],'value',0,...
                'callback','radiobuttonCanonical_Callback(get(gcbo,''parent''))');
hbuttn = uicontrol('parent',hfig,'style','pushbutton','tag','pushbuttonApplyRegMethod','string','Apply',...
                   'units','normalized','position',[.2 .1 .35 .15],...
                   'callback','pushbuttonApplyRegMethod_Callback');
               
while probeRegMethod.apply==0
   if ~ishandles(hfig)
       return;
   end
   pause(.1);
end

if probeRegMethod.anchor == 1
   method = 'anchor';
elseif probeRegMethod.canonical == 1
   method = 'canonical';
end

delete(hfig);



% ---------------------------------------------------------------------
function radiobuttonAnchor_Callback(hObject)
global probeRegMethod

hc = get(hObject,'children');

if strcmp(get(hc(1),'tag'),'radiobuttonAnchor')
    har = hc(1);
elseif strcmp(get(hc(2),'tag'),'radiobuttonAnchor')
    har = hc(2);
end
if strcmp(get(hc(1),'tag'),'radiobuttonCanonical')
    hcr = hc(1);
elseif strcmp(get(hc(2),'tag'),'radiobuttonCanonical')
    hcr = hc(2);
end

if get(har,'value')==1
    set(hcr,'value',0);
    probeRegMethod.anchor = 1;
    probeRegMethod.canonical = 0;
elseif get(har,'value')==0
    set(hcr,'value',1);
    probeRegMethod.anchor = 0;
    probeRegMethod.canonical = 1;
end



% ---------------------------------------------------------------------
function radiobuttonCanonical_Callback(hObject)
global probeRegMethod

hc = get(hObject,'children');

if strcmp(get(hc(1),'tag'),'radiobuttonCanonical')
    hcr = hc(1);
elseif strcmp(get(hc(2),'tag'),'radiobuttonCanonical')
    hcr = hc(2);
end
if strcmp(get(hc(1),'tag'),'radiobuttonAnchor')
    har = hc(1);
elseif strcmp(get(hc(2),'tag'),'radiobuttonAnchor')
    har = hc(2);
end

if get(hcr,'value')==1
    set(har,'value',0);
    probeRegMethod.canonical = 1;
    probeRegMethod.anchor = 0;
elseif get(hcr,'value')==0
    set(har,'value',1);
    probeRegMethod.canonical = 0;
    probeRegMethod.anchor = 1;
end



% ---------------------------------------------------------------------
function pushbuttonApplyRegMethod_Callback()
global probeRegMethod

probeRegMethod.apply = 1;

