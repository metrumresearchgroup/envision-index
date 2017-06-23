globals <- list()

message("envision-index 20")

globals$user <- Sys.info()[["user"]]
globals$appsLoc <- file.path("/data", "shiny-server")

globals$metrumGitHub <- "https://raw.githubusercontent.com/metrumresearchgroup"

globals$envisionIndexGitHub <- file.path(globals$metrumGitHub,
                                         "envision-index",
                                         "master")

globals$shinymetrumGitHub <- file.path(globals$metrumGitHub,
                                       "shinymetrum",
                                       "master")

source(file.path(globals$shinymetrumGitHub, "R", "metworx-app.R"))
