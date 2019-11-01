function axes_view = set_view_probe_geometry_axes2(hObject,optpos)

    axes_view='xy';
    if(isempty(optpos))
        return;
    end

    if(length(unique(optpos(:,3)))==1)
        set(hObject, 'view', [0 90]);
        axes_view='xy';
    elseif(length(unique(optpos(:,2)))==1)
        set(hObject, 'view', [0 0]);
        axes_view='xz';
    elseif(length(unique(optpos(:,1)))==1)
        set(hObject, 'view', [90 0]);
        axes_view='yz';
    end

