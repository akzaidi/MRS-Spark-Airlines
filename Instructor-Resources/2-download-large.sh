wget 'https://marinchshare1.blob.core.windows.net/weather1/WeatherRaw.tgz?st=2017-02-18T18%3A26%3A00Z&se=2018-01-19T18%3A26%3A00Z&sp=rl&sv=2015-12-11&sr=c&sig=vfxEQOnU%2BOmPZ%2BFKLHgesywv41Ld3mQ%2Bpfn3PLa2Imw%3D'

wget http://packages.revolutionanalytics.com/datasets/AirOnTime87to12/AirOnTimeCSV.zip

sudo apt-get install p7zip-full

7za x AirOnTimeCSV.zip
tar -xvzf 'WeatherRaw.tgz?sv=2014-02-14&sr=c&sig=Vhfq%2BSWZKHuzVzHATd4ij0Cp8nVF%2B%2FkBANm2JyrC1ho%3D&st=2016-04-06T07%3A00%3A00Z&se=2017-04-07T07%3A00%3A00Z&sp=r'

hdfs dfs -mkdir /FlightsLarge/
hdfs dfs -copyFromLocal WeatherRaw/ /FlightsLarge/
hdfs dfs -copyFromLocal AirOnTimeCSV/ /FlightsLarge/
