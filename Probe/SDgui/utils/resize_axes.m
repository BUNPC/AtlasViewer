function resize_axes(hObject,optpos)

    if(isempty(optpos))
        return;
    end

    xmin = min(optpos(:,1));
    xmax = max(optpos(:,1));
    ymin = min(optpos(:,2));
    ymax = max(optpos(:,2));
    zmin = min(optpos(:,3));
    zmax = max(optpos(:,3));
    nopt_x = length(unique(optpos(:,1)));
    nopt_y = length(unique(optpos(:,2)));
    nopt_z = length(unique(optpos(:,3)));
    if(length(unique(optpos(:,3)))==1)
        pz = 1;
    else
        pz = (zmax-zmin)/nopt_z;
    end
    if(length(unique(optpos(:,2)))==1)
        py = 1;
    else
        py = (ymax-ymin)/nopt_y;
    end
    if(length(unique(optpos(:,1)))==1)
        px = 1;
    else
        px = (xmax-xmin)/nopt_x;        
    end
    set(hObject, 'xlim', [xmin-px xmax+px]);
    set(hObject, 'ylim', [ymin-py ymax+py]);
    set(hObject, 'zlim', [zmin-pz zmax+pz]);
