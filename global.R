globals <- list()

message("envision-index 7")

globals$user <- Sys.info()[["user"]]

globals$metrumGitHub <- "https://raw.githubusercontent.com/metrumresearchgroup"

globals$envisionIndexGitHub <- file.path(globals$metrumGitHub,
                                         "envision-index",
                                         "master")

globals$shinymetrumGitHub <- file.path(globals$metrumGitHub,
                                       "shinymetrum",
                                       "master")

source(file.path(globals$shinymetrumGitHub, "R", "metrum-app.R"))
