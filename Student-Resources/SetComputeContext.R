isLinux <- Sys.info()["sysname"] == "Linux"

useHDFS <- isLinux
useRxSpark <- isLinux

if(useHDFS) {
  
  ################################################
  # Use Hadoop-compatible Distributed File System
  ################################################
  
  rxOptions(fileSystem = RxHdfsFileSystem())
  
  dataDir <- "/user/RevoShare/sshuser/delayDataLarge"
  whoami <- system('whoami', intern = TRUE)
  system(paste0('hdfs dfs -mkdir /user/RevoShare/', whoami))
  system(paste0('hdfs dfs -mkdir /user/RevoShare/', whoami, '/delayDataLarge'))
  ################################################
  
  if(rxOptions()$hdfsHost == "default") {
    fullDataDir <- dataDir
  } else {
    fullDataDir <- paste0(rxOptions()$hdfsHost, dataDir)
  }  
} else {
  
  ################################################
  # Use Native, Local File System
  ################################################
  
  rxOptions(fileSystem = RxNativeFileSystem())
  
  dataDir <- file.path(getwd(), "delayDataLarge")
  
  ################################################
}

if(useRxSpark) {
  
  ################################################
  # Distributed computing using Spark
  ################################################
  
  computeContext <- RxSpark(consoleOutput=TRUE)
  
  ################################################
  
} else {
  
  ################################################
  # Single-node Computing
  ################################################
  
  computeContext <- RxLocalSeq()
  
  ################################################
}

rxSetComputeContext(computeContext)
