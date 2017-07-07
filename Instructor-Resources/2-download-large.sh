wget 'https://marinchshare1.blob.core.windows.net/weather1/WeatherRaw.tgz?st=2017-02-18T18%3A26%3A00Z&se=2018-01-19T18%3A26%3A00Z&sp=rl&sv=2015-12-11&sr=c&sig=vfxEQOnU%2BOmPZ%2BFKLHgesywv41Ld3mQ%2Bpfn3PLa2Imw%3D' -O WeatherRaw.tgz

wget http://packages.revolutionanalytics.com/datasets/AirOnTime87to12/AirOnTimeCSV.zip

sudo apt-get install p7zip-full

7za x AirOnTimeCSV.zip
tar -xvzf 'WeatherRaw.tgz'

hdfs dfs -mkdir /FlightsLarge/
hdfs dfs -copyFromLocal WeatherRaw/ /FlightsLarge/
hdfs dfs -copyFromLocal AirOnTimeCSV/ /FlightsLarge/
 
