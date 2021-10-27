function axes_view = SDgui_set_axes_view(hObject, optpos)

if nargin == 1
    optpos = [];
end
axes_view = '';
if ischar(optpos)
    axes_view = optpos;
end

if isempty(optpos)
    axes_view = 'xy';
elseif isempty(axes_view)
    if length(unique(optpos(:,3)))==1
        axes_view='xy';
    elseif length(unique(optpos(:,2)))==1
        axes_view='xz';
    elseif length(unique(optpos(:,1)))==1
        axes_view='yz';
    else
        axes_view='xy';
    end
end

if ishandles(hObject)
    switch(axes_view)
        case {'xy', 'xyz'}
            set(hObject, 'view', [0 90]);
        case 'xz'
            set(hObject, 'view', [0 0]);
        case 'yz'
            set(hObject, 'view', [90 0]);
    end
end

