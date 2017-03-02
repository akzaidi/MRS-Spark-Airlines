wget 'https://marinchshare1.blob.core.windows.net/weather1/WeatherRaw.tgz?sv=2014-02-14&sr=c&sig=Vhfq%2BSWZKHuzVzHATd4ij0Cp8nVF%2B%2FkBANm2JyrC1ho%3D&st=2016-04-06T07%3A00%3A00Z&se=2017-04-07T07%3A00%3A00Z&sp=r' -o WeatherRaw.tgz

wget http://packages.revolutionanalytics.com/datasets/AirOnTime87to12/AirOnTimeCSV.zip

unzip AirOnTimeCSV.zip
tar -xvfz WeatherRaw.tgz

hdfs dfs -mkdir /FlightsLarge/
hdfs dfs -copyFromLocal WeatherRaw/ /FlightsLarge/
hdfs dfs -copyFromLocal AirOnTimeCSV/ /FlightsLarge/