function [I1p, bbp] = rectifyIm(I1, M1)
    s1 = size(I1);
    c1 = [[0,0];
          [0,s1(2)];
          [s1(2),0]; [s1(2),s1(1)]];

    c1p = projTrans(M1, c1);
    xmin = floor(min( c1p(:,1) ));
    ymin = floor(min( c1p(:,2) ));
    xmax = ceil(max( c1p(:,1) ));
    ymax = ceil(max( c1p(:,2) ));
    s = [xmax-xmin, ymax-ymin];
    Ht = [[1 0 -xmin]; [0,1,-ymin]; [0,0,1]];
    I1p = cv.warpPerspective(I1, Ht*M1, 'DSize', s);
end