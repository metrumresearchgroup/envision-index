envisionGlobals <- list()

envisionGlobals$user <- Sys.info()[["user"]]
envisionGlobals$appsLoc <- file.path("/data", "shiny-server")

envisionGlobals$metrumGitHub <- "https://raw.githubusercontent.com/metrumresearchgroup"

envisionGlobals$envisionIndexGitHub <- file.path(envisionGlobals$metrumGitHub,
                                                 "envision-index",
                                                 "master")
