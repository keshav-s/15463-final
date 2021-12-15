function [M1, M2, Kp, R_rect, t1p, t2p] = rectifyPair(K1, K2, R1, R2, t1, t2)
    c1 = -1*((K1 * R1) \ (K1 * t1));
    c2 = -1*((K2 * R2) \ (K2 * t2));
    
    % create R_rect
    r1 = (c1-c2)/norm(c1-c2);
    r2 = cross(R1(3,:)', r1);
    r3 = cross(r2, r1);
    R_rect = [r1(:) r2(:) r3(:)]';
    Kp = K2;
    t1p = -R_rect*c1;
    t2p = -R_rect*c2;

    M1 = (Kp*R_rect) / (K1*R1);
    M2 = (Kp*R_rect) / (K2*R2);
end