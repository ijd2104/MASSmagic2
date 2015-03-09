    parseXMLFile('TargetSites.xml');
    S = 
    S(ismember(S,' ')) = [];
    
    urlbuild=strcat('http://api.openweathermap.org/data/2.5/weather?q=',S);
    result=urlread(urlbuild);
    
    weather1 = strsplit(result,'"main":')
    weatherchar = char(weather1(2))
    weather3 = strsplit(weatherchar,',')
    finalweather = weather3(1)