r <- getOption("repos")
mran_date <- Sys.Date() - 1
r[["CRAN"]] <- paste0("https://mran.revolutionanalytics.com/snapshot/", mran_date)
options(repos = r)

pkgs <- c("sparklyr", "tidyverse")

install.packages(pkgs)

if(!require("devtools")) install.packages("devtools")
devtools::install_github("bwlewis/rthreejs")

install.packages(c("rmarkdown", "knitr", "formatR"))
