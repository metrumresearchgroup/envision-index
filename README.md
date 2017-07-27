# Envision Index App
This is the code to place at `/data/shiny-server` on a Metworx Envision workflow.

It includes an html template (`index.html`) that directs the user to the `index` app. It also has example applications (`hello` & `rmd`).

[](#description-file-in-envision)
## DESCRIPTION file in Envision apps

Metworx envision allows shiny app developers to specify options at the app level via a DESCRIPTION file.

The DESCRIPTION file should be placed the same level as the code for the app (where server.R/ui.R or app.R are located).

### Exhaustive list of Envision DESCRIPTION file options:

#### `EnvisionName`
  * Type: Character
  * Default: ""
  * Description: App display name.
  * Example: `EnvisionName: It's Alive`

#### `EnvisionDescription`
  * Type: Character
  * Default: ""
  * Description: App description.
  * Example: `EnvisionDescription: Simple example demonstrating a shiny app and the DESCRIPTION file`

#### `EnvisionUsers`
  * Type: String
  * Default: all
  * Description: Which users can view the app in the Envision Dashboard?
  * Example: `EnvisionUsers: user1 user2`

#### `EnvisionTileLocation`
  * Type: Character
  * Default: NULL
  * Description: Location of the image file to display as app tile.
  * Example: `EnvisionTileLocation: /data/shiny-server/hello/tile.png`

### Example Result
![Example](https://raw.githubusercontent.com/metrumresearchgroup/envision-index/master/img/DESCRIPTION-example.png)

Download example DESCRIPTION file [here](https://github.com/metrumresearchgroup/envision-index/raw/master/code-for-envision/hello/DESCRIPTION).
  