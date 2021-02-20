function probe = displaySprings(probe)

if ~isempty(probe.optpos_reg)
    optpos = probe.optpos_reg;
elseif ~isempty(probe.optpos)
    optpos = probe.optpos;
else
    return;
end

hOptodes   = probe.handles.hOptodes;
sl         = probe.registration.sl;

cm = [0 0 1; 0 1 1; 0 0 0; 1 1 0; 1 0 0];
sLenThresh = probe.springLenThresh;


hold on
hSprings = [];
for ii=1:size(sl,1)
    springLenReg(ii) = dist3(optpos(sl(ii,1),:), optpos(sl(ii,2),:));
    springLenErr(ii) = springLenReg(ii)-sl(ii,3);
    if springLenErr(ii)<-sLenThresh(2)
        k = 1;
    elseif springLenErr(ii)<-sLenThresh(1)
        k = 2;
    elseif springLenErr(ii)>sLenThresh(2)
        k = 5;
    elseif springLenErr(ii)>sLenThresh(1)
        k = 4;
    else
        k = 3;
    end
   
    type = get(hOptodes(sl(ii,1)),'type');
    if strcmp(type,'text')
        pos1 = get(hOptodes(sl(ii,1)),'position');
        pos2 = get(hOptodes(sl(ii,2)),'position');
    elseif strcmp(type,'line')
        pos1 = cell2array(get(hOptodes(sl(ii,1)),{'xdata','ydata','zdata'}));
        pos2 = cell2array(get(hOptodes(sl(ii,2)),{'xdata','ydata','zdata'}));
    end
    hSprings(ii) = line([pos1(1,1) pos2(1,1)], [pos1(1,2) pos2(1,2)], [pos1(1,3) pos2(1,3)],...
                        'linewidth',2,'color',cm(k,:));
end
hold off   

probe.handles.hSprings = hSprings;
