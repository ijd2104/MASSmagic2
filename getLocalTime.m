function [ str ] = getLocalTime(lat,lon)
    urlbuild=strcat('http://www.earthtools.org/timezone/',num2str(lat),'/',num2str(lon));
    try
        result=char(urlread(urlbuild));
        str1 = strsplit(result,'localtime');
        str2 = char(str1(2));
        str3 = str2(2:end-2);
        str=str3;
    catch
        str='N/A';
    end
end