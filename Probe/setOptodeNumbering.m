function probe = setOptodeNumbering(probe)

hOidx         = probe.hOptodesIdx;
nsrc          = probe.nsrc;
optViewMode   = probe.optViewMode;
if strcmp(optViewMode,'numbers') & ~isempty(probe.handles.hOptodes)
    set(probe.handles.hOptodes(:,hOidx), 'visible','on');
    set(probe.handles.hOptodesCircles(:,hOidx), 'visible','off');
    hOptodes      = probe.handles.hOptodes;
    val2 = 0;
elseif strcmp(optViewMode,'circles') & ~isempty(probe.handles.hOptodes)
    set(probe.handles.hOptodes(:,hOidx), 'visible','off');
    set(probe.handles.hOptodesCircles(:,hOidx), 'visible','on');
    hOptodes      = probe.handles.hOptodesCircles;
    val2 = 1;
else
    return
end
val1 = get(probe.handles.checkboxOptodeSDMode,'value');

if  val1==1 

    if val2==0
        for ii=1:size(hOptodes,1)
            if ii<=nsrc
                set(hOptodes(ii,hOidx), 'string',num2str(ii));
                set(hOptodes(ii,hOidx), 'color','r');
            else
                set(hOptodes(ii,hOidx), 'string',num2str(ii-nsrc));
                set(hOptodes(ii,hOidx), 'color','b');
            end
        end
    elseif val2==1
        set(hOptodes(1:nsrc,hOidx), 'color','r');
        set(hOptodes(nsrc+1:end,hOidx), 'color','b');
    end
    
elseif val1==0

    if val2==0
        for ii=1:size(hOptodes,1)
            set(hOptodes(ii,hOidx), 'string',num2str(ii));
            set(hOptodes(ii,hOidx), 'color','r');
        end
    elseif val2==1
        set(hOptodes(:,hOidx), 'color','r');
    end
    
end
