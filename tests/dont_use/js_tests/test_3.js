casper.then(function(){
  this.click("a[href='#shiny-tab-logs']");
});

casper.then(function() {
casper.evaluate(function() {
  Shiny.onInputChange("logApp", "hello");
});
});

casper.then(function(){
    this.wait(2000);
});
