.libPaths("lib")

library(shinydashboard)

EnvisionFields <- c("EnvisionName", "EnvisionDescription", "EnvisionTileLocation", "EnvisionUsers")

EnvisionUser <- Sys.info()[["user"]]
