
# index.html --------------------------------------------------------------
system("sudo cp /data/shiny-server/envision-index/misc/files/index.html /data/shiny-server/index.html")


# shiny-server.conf -------------------------------------------------------
shiny_server_conf <- "/etc/shiny-server/shiny-server.conf"
system(paste0("sudo chmod 0777 ", shiny_server_conf))
system(paste0("sudo cp /data/shiny-server/envision-index/misc/files/shiny-server.conf ", shiny_server_conf))
system("sudo restart shiny-server")


# Make log readable / writable --------------------------------------------
system("sudo chmod -R 0777 /var/log/shiny-server")
# system("sudo chmod g+s /var/log/shiny-server")


# Make www folder in index readable / writable ----------------------------
system("sudo chmod -R 0777 /data/shiny-server/envision-index/www")
# system("sudo chmod g+s /data/shiny-server/index/www")


# Set up the hello app to use envision-index ------------------------------
system("sudo rm -rf /data/shiny-server/hello")
system("sudo cp -rf /data/shiny-server/envision-index/misc/example-app/hello /data/shiny-server/hello")
