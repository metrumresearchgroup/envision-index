
library(shinydashboard)# , lib.loc = "lib")

EnvisionFields <- c("EnvisionName", "EnvisionDescription", "EnvisionTileLocation", "EnvisionUsers")

EnvisionUser <- Sys.info()[["user"]]

EnvisionAppsLocation <- "/data/shiny-server"

EnvisionAppsLogDirectory <- "/var/log/shiny-server"
