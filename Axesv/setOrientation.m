function axesv = setOrientation(axesv,verr,verl,horr,horl,up,down)

% Usage:      setOrientation(axesv,verr,verl,horr,horl,up,down)

axesv = rotVerticalLeft(axesv, verl);
axesv = rotVerticalRight(axesv, verr);
axesv = rotUp(axesv, up);
axesv = rotDown(axesv, down);
axesv = rotHorizontalLeft(axesv, horl);
axesv = rotHorizontalRight(axesv, horr);



