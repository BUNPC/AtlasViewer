function refpts = setRefptsMenuItemSelection(refpts)

switch(refpts.eeg_system.selected)
    case '10-20'
        set(refpts.handles.menuItemShow10_20,'checked','on');
        set(refpts.handles.menuItemShow10_10,'checked','off');
        set(refpts.handles.menuItemShow10_5,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_20,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_10,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_5,'checked','off');
    case '10-10'
        set(refpts.handles.menuItemShow10_20,'checked','off');
        set(refpts.handles.menuItemShow10_10,'checked','on');
        set(refpts.handles.menuItemShow10_5,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_20,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_10,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_5,'checked','off');
    case '10-5'
        set(refpts.handles.menuItemShow10_20,'checked','off');
        set(refpts.handles.menuItemShow10_10,'checked','off');
        set(refpts.handles.menuItemShow10_5,'checked','on');
        set(refpts.handles.menuItemShowSelectedCurves,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_20,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_10,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_5,'checked','off');
    case '10-2-5'
    case '10-1'
    case 'selected_curves_10_20'
        set(refpts.handles.menuItemShow10_20,'checked','off');
        set(refpts.handles.menuItemShow10_10,'checked','off');
        set(refpts.handles.menuItemShow10_5,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves,'checked','on');
        set(refpts.handles.menuItemShowSelectedCurves10_20,'checked','on');
        set(refpts.handles.menuItemShowSelectedCurves10_10,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_5,'checked','off');
    case 'selected_curves_10_10'
        set(refpts.handles.menuItemShow10_20,'checked','off');
        set(refpts.handles.menuItemShow10_10,'checked','off');
        set(refpts.handles.menuItemShow10_5,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves,'checked','on');
        set(refpts.handles.menuItemShowSelectedCurves10_20,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_10,'checked','on');
        set(refpts.handles.menuItemShowSelectedCurves10_5,'checked','off');
    case 'selected_curves_10_5'
        set(refpts.handles.menuItemShow10_20,'checked','off');
        set(refpts.handles.menuItemShow10_10,'checked','off');
        set(refpts.handles.menuItemShow10_5,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves,'checked','on');
        set(refpts.handles.menuItemShowSelectedCurves10_20,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_10,'checked','off');
        set(refpts.handles.menuItemShowSelectedCurves10_5,'checked','on');
end

