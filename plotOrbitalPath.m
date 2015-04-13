function [x1,x2,y1,y2] = plotOrbitalPath(lat1)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
[lat2,lon2] = getISScoord();

%normalize
lat1 = lat1/51.8;
lat2 = lat2/51.8;

if lat2<lat1
    t = pi-asin(lat2);
else
    t = asin(lat2);
end

x = t-pi:2*pi/99:t+pi; %100 points
x = 51.8*sin(x);

m = 0.061791;
t = lon2/m;

y = t-2872.58:5745.16/99:t+2872.58; %100 points
if t>0
    H = heaviside(y-2872.58);
    y = y-5745.16*H;
    i = find(H,1);
else
    H = heaviside(abs(y)-2872.58);
    y = y+5745.16*H;
    i = find(~H,1);
end
y = m*y;

data1 = [x(1:i-1)' y(1:i-1)'];
data2 = [x(i:end)' y(i:end)'];
imgH = 599;
imgW = 773;
[x1,y1] = mercatorProjection(data1(:,2),data1(:,1), imgW, imgH);
[x2,y2] = mercatorProjection(data2(:,2),data2(:,1), imgW, imgH);
end