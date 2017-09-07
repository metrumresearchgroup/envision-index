take_envision_webshot <- function(out_file, casper_code = ""){
    webshot::webshot(
      url = 
        paste0(workflowURL, "/envision/index/"),
      
      file = 
        paste0("screen-shots/", out_file),
      
      eval = 
        paste0(
          "
       casper.then(function() {
        this.sendKeys('input[type=\"text\"]', '", username, "');
        this.sendKeys('input[type=\"password\"]', '", password, "');
        this.click('input[type=\"submit\"]');
         this.wait(4000);",
          casper_code, "
         }); 
         ")
    )
}
