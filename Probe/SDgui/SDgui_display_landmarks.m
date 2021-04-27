function h_lm = SDgui_display_landmarks(haxes, landmarks)

h_lm = [];

if isempty(landmarks)
    return
end
if isempty(landmarks.labels)
    return
end

% Draw landmarks
if strcmpi(haxes.Tag, 'probe_geometry_axes')
    col = [140/255, 100/255,  80/255];
else
    col = [80/255, 100/255,  140/255];
end
for i = 1:length(landmarks.labels)
    p = landmarks.pos(i,:);
    h_lm(i) = text(haxes, p(1),p(2),p(3), landmarks.labels{i}, 'color',col, ...
                        'fontweight','bold', 'fontsize',12,...
                        'verticalalignment','middle', 'horizontalalignment','center'); %#ok<AGROW>
    set(h_lm(i), 'hittest','off');
end

