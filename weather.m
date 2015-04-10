function [currentweather] = weather(S)
    %This function calls the weather from the the target destination
    S(ismember(S,' ')) = [];
    
    urlbuild=strcat('http://api.openweathermap.org/data/2.5/weather?q=',S);
    try
        result=urlread(urlbuild);

        errorread = char(result);
        a = strfind(errorread,'Error');
        if a>0
            currentweather = ' ';
        else 
            weather1 = strsplit(result,'"main":');
            weatherchar = char(weather1(2));
            weather3 = strsplit(weatherchar,',');
            currentweather = weather3(1);
            currentweather = char(currentweather);
            currentweather = currentweather(2:end-1);
        end
    catch
    end
end
