# envision-index
This is landing page for the Envision feature of Metworx.

The majority of the code for the envision-index application will be sourced live from this GitHub repo. The code that will get uploaded to a Metworx disk (on build, automatically) is found in [code-for-envision-index](https://github.com/metrumresearchgroup/envision-index/tree/master/code-for-envision).
If the sourced code fails, there is a fallback application (uploaded to the Metworx disk) that will give users access to their envision apps.

[](#description-file-in-envision)
## DESCRIPTION file in Envision apps

The envision-index allows users to specify options at the app level, via a DESCRIPTION file.

### Exhaustive list of Envision DESCRIPTION file options

**EnvisionName**
  * Type: Character
  * Default: ""
  * Description: Name for application display on envision-index.
  * Example: `EnvisionName: It's Alive`

**EnvisionDescription**
  * Type: Character
  * Default: ""
  * Description: Description for application display on envision-index.
  * Example: `EnvisionDescription: Simple example demonstrating a shiny app and the DESCRIPTION file`

**EnvisionViewLogs**
  * Type: Boolean
  * Default: TRUE
  * Description: Should a "View Logs" button appear on the envision-index?
  * Example: `EnvisionViewLogs: TRUE`

**EnvisionTileLocation**
  * Type: Character
  * Default: NULL
  * Description: Location of the image file to display as app tile in envision-index.
  * Example: `EnvisionTileLocation: /data/shiny-server/hello/tile.png`

## Example Result
![Example](https://raw.githubusercontent.com/metrumresearchgroup/envision-index/master/img/DESCRIPTION-example.png)

Download example DESCRIPTION file [here](https://github.com/metrumresearchgroup/envision-index/raw/master/code-for-envision/hello/DESCRIPTION).
  