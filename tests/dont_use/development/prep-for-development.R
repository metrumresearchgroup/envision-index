
# app code
system("rm -rf /data/shiny-server/*")

for(to_move.i in c("index", "index.html", "hello", "rmd")){
  
  system(paste0("cp -R /data/envision-index/", to_move.i, " /data/shiny-server/", to_move.i))
  
}


# shiny-server.conf
shiny_server_conf <- "/etc/shiny-server/shiny-server.conf"

system(paste0("sudo chmod 0777 ", shiny_server_conf))

system(paste0("sudo cp /data/envision-index/tests/development/shiny-server.conf ", shiny_server_conf))

system("sudo restart shiny-server")
