$(document).ready(function() {

  $(".documentation").hide();

  $(".btn-slide").click(function(){
    if ($(".documentation").is(":hidden")) {
        $('.showOrHide').remove();
        var a = $("<span>Hide Walkthroug<\/span>").addClass("showOrHide");
        $('.btn-slide').append(a);
        $(".documentation").slideDown("fast");
        var isHidden = "show";
        var dataString = 'isHidden='+ isHidden;
        $.ajax({
          dataType: "html",
          type: "POST",
          url: "/submit/Account/ShowHideWalkthrough",
          data: dataString
        });
        return false;
    } else {
        $('.showOrHide').remove();
        var a = $("<span>Show Walkthrough<\/span>").addClass("showOrHide");
        $('.btn-slide').append(a);
        $(".documentation").slideUp("fast");
        var isHidden = "hide";
        var dataString = 'isHidden='+ isHidden;
        $.ajax({
          dataType: "html",
          type: "POST",
          url: "/submit/Account/ShowHideWalkthrough",
          data: dataString
        });
        return false;
    }
  });

  $(".btn-hide").click(function(){
        $('.showOrHide').remove();
        var a = $("<span>Show Walkthrough<\/span>").addClass("showOrHide");
        $('.btn-slide').append(a);
        $(".documentation").slideUp("fast");
  });

});
