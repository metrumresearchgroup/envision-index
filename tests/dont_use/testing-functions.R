# All testing js script must have colons ";" at the end of each line
# (which is a javascript standard)

take_envision_webshot <- function(js_test){
  
  test_code <- paste(readLines(paste0("js_tests/", js_test, ".js")), collapse = "")
  
  eval_code <- paste0(
    "casper.then(function() {
        this.sendKeys('input[type=\"text\"]', '", username, "');
        this.sendKeys('input[type=\"password\"]', '", password, "');
        this.click('input[type=\"submit\"]');
        this.wait(5000);
        });",
    test_code
  )
  
  message(cat(eval_code))
  
  webshot::webshot(
    
    url = paste0(workflowURL, "/envision/index/"),
    
    file = paste0("screen-shots/", js_test, ".png"),
    
    eval = eval_code
  
  )
  
}
