## Quickstart:

### Start with command line:
1) Run: `cd /data/shiny-server`
2) Run: `git clone https://github.com/metrumresearchgroup/envision-index.git`

### Open RStudio
1) Click on the (open) file: `/data/shiny-server/envision-index/envision-index.Rproj`
2) Wait for packages to install

### Run an R Script
1) Run the R script: `/data/shiny-server/envision-index/misc/prep-for-use.R`

# Envision Index App
This is the code to place at `/data/shiny-server` on a Metworx Envision workflow.

[](#description-file-in-envision)
## DESCRIPTION file in Envision apps

Metworx envision allows shiny app developers to specify options at the app level via a DESCRIPTION file.

The DESCRIPTION file should be placed at the same level as the code for the app (where `server.R` & `ui.R` or `app.R` are located).

### Exhaustive list of Envision DESCRIPTION file options:

#### `EnvisionName`
  * Type: Character
  * Default: `the app folder name`
  * Description: App display name.
  * Example: `EnvisionName: It's Alive`

#### `EnvisionDescription`
  * Type: Character
  * Default: ` `
  * Description: App description.
  * Example: `EnvisionDescription: Simple example demonstrating a shiny app and the DESCRIPTION file`

#### `EnvisionUsers`
  * Type: Space delimited character vector
  * Default: `all`
  * Description: Which users can view the app in the Envision Dashboard?
  * Example: `EnvisionUsers: user1 user2`

#### `EnvisionTileLocation`
  * Type: Character
  * Default: `default-tile.png`
  * Description: Location of the image file to display as app tile.
  * Example: `EnvisionTileLocation: /data/shiny-server/hello/tile.png`


Download example DESCRIPTION file [here](https://raw.githubusercontent.com/metrumresearchgroup/envision-index/master/misc/example-app/hello/DESCRIPTION).
  