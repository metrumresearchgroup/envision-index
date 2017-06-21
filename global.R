globals <- list()

message("envision-index v3")

globals$user <- Sys.info()[["user"]]

globals$apps <- sort(list.dirs(recursive = FALSE, full.names = FALSE))

globals$metrumGitHub <- "https://raw.githubusercontent.com/metrumresearchgroup"

globals$envisionIndexGitHub <- file.path(globals$metrumGitHub,
                                         "envision-index",
                                         "master")

globals$shinymetrumGitHub <- file.path(globals$metrumGitHub,
                                       "shinymetrum",
                                       "master")

source(file.path(globals$shinymetrumGitHub, "R", "metrum-app.R"))
