envisionGlobals <- list()

message("envision-index 28")

envisionGlobals$user <- Sys.info()[["user"]]
envisionGlobals$appsLoc <- file.path("/data", "shiny-server")

envisionGlobals$metrumGitHub <- "https://raw.githubusercontent.com/metrumresearchgroup"

envisionGlobals$envisionIndexGitHub <- file.path(envisionGlobals$metrumGitHub,
                                                 "envision-index",
                                                 "master")

envisionGlobals$shinymetrumGitHub <- file.path(envisionGlobals$metrumGitHub,
                                               "shinymetrum",
                                               "master")

source(file.path(envisionGlobals$shinymetrumGitHub, "R", "metrum-app.R"))

