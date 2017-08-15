$(document).ready(function () {
    Shiny.addCustomMessageHandler("envisionIndexJS",
        function (code) {
            eval(code);
        });
        
      $("body").addClass("skin-blue-light");
});

/*
function getAppLink(app) {
  var curLocation = window.location.href.split("/");
  var newLocation = curLocation[curLocation.length - 1] = app;
  newLocation = newLocation.join('/');
  
  return appLink
}
*/
function resizeLogOutput() {
    $("#logContents").css("max-height", $(window).height() - 255);
}

function scrollBottomLog() {
    $("#logContents").scrollTop($("#logContents")[0].scrollHeight);
}

$(window).on("resize", function () {
    resizeLogOutput();
    if ($("#liveStream")[0].checked) {
        scrollBottomLog();
    }
});

$(document).ready(function () {
    resizeLogOutput();
    $("#logContents").bind("DOMSubtreeModified", function () {
        scrollBottomLog();
    });
});

$(document).on("change", "#liveStream", function () {
    if ($("#liveStream")[0].checked) {
        scrollBottomLog();
    }
});

$(document).on("click", ".metrum-log-button", function () {
    $("#envision-app-table").hide();
    $("#envision-log-reader").css("visibility", "initial");
    Shiny.onInputChange("logApp", $(this).attr("id"));
    Shiny.onInputChange("indexDisplay", "logs");
});

$(document).on("click", "#showApps", function () {
    $("#envision-log-reader").css("visibility", "hidden");
    $("#envision-app-table").show();
    Shiny.onInputChange("indexDisplay", "apps");
});
