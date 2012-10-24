  $(function() {
    $('.error').hide();
    $(".button").click(function() {
      // validate and process form here
    var dataString = 'username='+ $("input#username").val() + '&password=' + $("input#password").val();
    alert(dataString);
    return false;  
    $.ajax({
      type: "POST",
      url: "/site/url.mas?path=/submit/Login&query=",
      data: dataString,
      success: function() {
        $('#modal').html("<div id='message'></div>");
        $('#message').html("<h2>Contact Form Submitted!</h2>")
        .append("/LoginSuccess");
      }
    });
    return false; 
       
    });
  });
  
