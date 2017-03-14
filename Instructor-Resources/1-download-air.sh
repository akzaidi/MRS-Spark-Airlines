wget http://cdspsparksamples.blob.core.windows.net/data/Airline/WeatherSubsetCsv.tar.gz
wget http://cdspsparksamples.blob.core.windows.net/data/Airline/AirlineSubsetCsv.tar.gz

gunzip WeatherSubsetCsv.tar.gz
gunzip AirlineSubsetCsv.tar.gz
tar -xvf WeatherSubsetCsv.tar
tar -xvf AirlineSubsetCsv.tar
rm WeatherSubsetCsv.tar AirlineSubsetCsv.tar

hdfs dfs -mkdir /FlightData/

hdfs dfs -copyFromLocal AirlineSubsetCsv/ /FlightData/
hdfs dfs -copyFromLocal WeatherSubsetCsv /FlightData/

Rscript ./install-pkgs.R

wget https://raw.githubusercontent.com/akzaidi/etc/master/inst/install-rstudio-ubuntu.sh
chmod +x ./install-rstudio-ubuntu.sh
./install-rstudio-ubuntu.sh