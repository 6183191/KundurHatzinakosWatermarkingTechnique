clear all;
X = imread('barbara.jpg');
load('watermark.mat');
x = 1;
Q = 4;
N = 2;
seed = size(X);
rng(seed(1));
for i = N : -1 : 1
    ll = X;
    for j = 1:i
        [ll, lh, hl, hh] = dwt2(ll, 'haar'); 
    end
    if i == N
        newaverage = ll;
    end
    [row, col] = size(ll);
    key = randi([0, 1], row, col);
    for j = 1 : row
        for k = 1 : col
            if key(j,k) == 0
                continue;
            else
                coeff = [lh(j,k) hl(j,k) hh(j,k)];
                [mx, loc1] = max(coeff);
                [mn, loc3] = min(coeff);
                loc2 = 6-loc1-loc3;
                mid = coeff(loc2);
                interval = (mx-mn)/(2*Q-1);
                
                if watermark(x,1) == 0
                    gen_int = mn:2*interval: mx-interval;
                    [minval, loc] = min(abs(gen_int - mid));
                    newval = gen_int(loc);
                else %watermark is one
                    gen_int = mn+interval:2*interval: mx;
                    [minval, loc] = min(abs(gen_int - mid));
                    newval = gen_int(loc);
                end
                if loc2 == 1
                    lh(j,k) = newval;
                else
                    if loc2 == 2
                        hl(j,k) = newval;
                    else
                        hh(j,k) = newval;
                    end
                end
                x = x+1;
                x = rem(x,91);
                if x == 0
                    x = 1;
                end
            end
        end
    end
    newaverage = idwt2(newaverage(1:size(lh), 1:size(lh)),lh,hl,hh, 'haar');
end

for i = 1 : row
    for j = 1 : col
        newaverage(i,j) = floor(newaverage(i,j));
    end
end
imwrite(newaverage/256,'barbarawm.png');
save('barbarawm.mat', 'newaverage');
Y = imread('barbarawm.png');
psnrvalue = psnr(X,Y)