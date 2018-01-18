function d =  rect_distance(bb1,bb2)
x1 = bb1(1); y1 = bb1(2); x1b = bb1(1) + bb1(3); y1b = bb1(2) + bb1(4);
x2 = bb2(1); y2 = bb2(2); x2b = bb2(1) + bb2(3); y2b = bb2(2) + bb2(4);
left = x2b < x1;
right = x1b < x2;
bottom = y2b < y1;
top = y1b < y2;
if top && left
    d = dist(x1, y1b, x2b, y2);
elseif left  && bottom
    d = dist(x1, y1, x2b, y2b);
elseif bottom  && right
    d = dist(x1b, y1, x2, y2b);
elseif right  && top
    d = dist(x1b, y1b, x2, y2);
elseif left
    d = x1 - x2b;
elseif right
    d = x2 - x1b;
elseif bottom
    d = y1 - y2b;
elseif top
    d = y2 - y1b;
else
    d = 0;
end

function d = dist(x1,y1,x2,y2)
d = sqrt((x2 - x1)^2 + (y2 - y1)^2);