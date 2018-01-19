clear all;
Q = 4;
load('barbarawm.mat');
load('watermark.mat');
X = newaverage;
seed = size(X);
rng(seed(1));
x = 1;
wm = zeros(90,1);
N = 2;
count = 0;

for i = N : -1 : 1
    ll = X;
    for j = 1:i
        [ll, lh, hl, hh] = dwt2(ll, 'haar');
    end
    [row, col] = size(ll);
    key = randi([0, 1], row, col);
    for j = 1 : row
        for k = 1 : col
            if key(j,k) == 0
                continue;
            else
                count = count+1;
                coeff = [lh(j,k) hl(j,k) hh(j,k)];
                [mx, loc1] = max(coeff);
                [mn, loc3] = min(coeff);
                loc2 = 6-loc1-loc3;
                if loc1 == loc3
                    loc2 = 1;
                end    
                mid = coeff(loc2);
                interval = (mx-mn)/(2*Q-1);
                
                gen_int = mn:2*interval: mx-interval;
                gen_int = gen_int - mid;
                gen_int = abs(gen_int);
                if min(gen_int) < 0.00009
                    wm(x,1) = wm(x,1) + 0;
                else
                    gen_int = mn+interval:2*interval: mx;
                    gen_int = gen_int - mid;
                    gen_int = abs(gen_int);
                    if min(gen_int) < 0.00009
                        wm(x,1) = wm(x,1) + 1;
                    else
                        wm(x,1) = wm(x,1) + 2;
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
end

a = floor(count/90);
for i = 1 : 90
    if wm(i,1)/a < 0.5
        wm(i,1) = 0;
    else
        wm(i,1) = 1;
    end
end

similarity = corr(watermark, wm)