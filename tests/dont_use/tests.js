function test_1(workFlow, username, password){

       casper.then(function() {
        this.sendKeys('input[type=\"text\"]', '", username, "');
        this.sendKeys('input[type=\"password\"]', '", password, "');
        this.click('input[type=\"submit\"]');
         this.wait(4000);",
          casper_code, "
         });
}

function test_2(workFlow){
  casper.click('a[href=https://i-0e72b8144a6559c76.metworx.com/envision/hello]')
}