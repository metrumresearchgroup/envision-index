.libPaths("lib")
library(webshot)

# Testing Steps

# Create a Metworx Envision Wf with password set to 'indextesting'

password <- "indextesting"

webshot("https://i-02226ccaed6ba0fdd.metworx.com/envision/index/",
        "test.png",
        eval = 
          paste0(
            "
casper.then(function() {
        this.sendKeys('input[type=\"text\"]', '", Sys.info()[['user']], "');
        this.sendKeys('input[type=\"password\"]', 'indextesting');
        this.click('input[type=\"submit\"]');
         this.wait(2000);
         }); 
         ")
)

