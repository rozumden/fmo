function d = distanceFromLine(linePt1, linePt2, pt)
%Function distanceFromLine calculates perpendicular distance of a point
%from a line specified by 2 points
%
%Input:
%linePt1 ... x and y coordinates of 1st line point
%linePt2 ... x and y coordinates of 2nd line point
%pt      ... x and y coordinates of a point
%
%Output:
%d ... perpendicular distance of pt from line intersecting linePt1 and
%linePt2

a = linePt2(2) - linePt1(2);
b = linePt2(1) - linePt1(1);

d = abs(...
        a * pt(1) - ... 
        b * pt(2) + ...
        linePt2(1) * linePt1(2) - ...
        linePt2(2) * linePt1(1) ...
        ) / sqrt(a^2 + b^2);