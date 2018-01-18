function mask = printLine(mask, x, y)
%Function printLine prints a line into binary image, setting points on the
%line to zero
%
%input: 
%mask ... binary mask in which line will be printed into
%x ... 2-by-1 matrix containing x-coordinate of line start and end
%y ... 2-by-1 matrix containing y-coorditate of line start and end
%
%output:
%mask ... binary mask in which points on the line have 0 value

    x1 = x(1);
    x2 = x(2);
    y1 = y(1);
    y2 = y(2);    
    if abs(x1-x2) < abs(y1-y2)
        if y1 > y2
            [x1, x2] = deal(x2,x1);
            [y1, y2] = deal(y2,y1);
        end
        ys = y1:y2;             
        xs = round(x1+(ys-y1)*((x2-x1)/(y2-y1)));
    else
        if x1 > x2
            [x1, x2] = deal(x2,x1);
            [y1, y2] = deal(y2,y1);
        end        
        xs = x1:x2;
        ys = round(y1+(xs-x1)*((y2-y1)/(x2-x1)));
    end
    linearInd = sub2ind(size(mask), ys, xs);
    mask(linearInd) = 0;    
end
