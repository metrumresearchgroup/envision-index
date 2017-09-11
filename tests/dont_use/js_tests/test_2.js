casper.then(function() {
  this.click('#hello-link');
  this.waitForPopup(function(){
    this.withPopup();
  });
  
});
