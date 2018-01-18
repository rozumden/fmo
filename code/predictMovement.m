function bbs = predictMovement(majorAxisLength, orientation, bb)
%Function predictMovement predicts a movement of a bounding box
%
%input: 
%majorAxisLength ... length of major axis of object's circumscribing
%                    ellipse
%orientation ... orientation of object's circumscribing ellipse in degrees
%bb ... axis-aligned bounding box of the object
%
%output:
%bbs ... 2-by-4 matrix containing 2 prediction bounding boxes, one for each
%        direction

rad = deg2rad(-orientation);
vec = rotationMatrix(rad) * [1; 0] * majorAxisLength;
vec = [vec' 0 0];

bb1 = bb + vec;
bb2 = bb - vec;

bbs = [bb1; bb2];

