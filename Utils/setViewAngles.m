function [cp_new, v_up] = setViewAngles(hAxes, o, az, el)

cp0 = get(hAxes, 'CameraPosition');
ct0 = get(hAxes, 'CameraTarget');

cp_new = calcCameraPosition(cp0, ct0, az, el, o);
[v_up_sup, v_up_ant] = calcCameraUpVectors(o);

% If camera up vector coinciding with Superior axis is on same line 
% as view axis, then we have to recalculate a cam up vector coinciding 
% with Anterior
viewAxis = ct0 - cp_new;
if angleBetweenVectors(abs(viewAxis), abs(v_up_sup))==0
    v_up = v_up_ant;
else
    v_up = v_up_sup;
end

% Sanity check
if isempty(v_up)
    return;
end

set(hAxes, 'CameraUpVector',v_up);
set(hAxes, 'CameraPosition',cp_new);
drawnow;

fprintf('Azimuth          : %0.1f\n', az);
fprintf('Elevation        : %0.1f\n', el);
fprintf('Orientation      : %s\n', o);
fprintf('Cam target       : [%0.1f, %0.1f, %0.1f]\n', ct0(1), ct0(2), ct0(3));
fprintf('Cam old position : [%0.1f, %0.1f, %0.1f]\n', cp0(1), cp0(2), cp0(3));
fprintf('Cam new position : [%0.1f, %0.1f, %0.1f]\n', cp_new(1), cp_new(2), cp_new(3));
fprintf('Camera up vector : [%0.1f, %0.1f, %0.1f]\n', v_up(1), v_up(2), v_up(3));
fprintf('View axis old    : [%0.1f, %0.1f, %0.1f]\n', ct0(1)-cp0(1), ct0(2)-cp0(2), ct0(3)-cp0(3));
fprintf('View axis new    : [%0.1f, %0.1f, %0.1f]\n', ct0(1)-cp_new(1), ct0(2)-cp_new(2), ct0(3)-cp_new(3));
fprintf('\n');

