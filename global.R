globals <- list()

globals$user <- Sys.info()[["user"]]

apps <- sort(list.dirs('/data/shiny-server', recursive = FALSE, full.names = FALSE))
notApps <- c("envision-index")

globals$apps <- apps[!(apps %in% notApps)]

source('https://raw.githubusercontent.com/metrumresearchgroup/shinymetrum/master/R/metrum-app.R')
