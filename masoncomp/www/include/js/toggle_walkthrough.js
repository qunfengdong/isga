// Author:              Matt Rossi
// Website:             ifohdesigns.com
// Article Source:      http://ifohdesigns.com/blog/tutorials/
// Last Modified:       August 27, 2008// IF YOU WISH TO USE THIS SCRIPT I WOULD APPRECIATE A BACKLINK

$(document).ready(function() {
$(".documentation").hide();
// var a = $("<a>Toggle Tutorial</a>").attr('href','#').addClass("btn-slide");
// $('#footer').before(a);
$(".btn-slide").click(function(){
if ($(".documentation").is(":hidden")) {
        $(".documentation").slideDown("fast");
// $(this).addClass("active");
         $.cookie('showTop', 'collapsed', { path: '/' });
 return false;
} else {
        $(".documentation").slideUp("fast");
// $(this).removeClass("active");
        $.cookie('showTop', 'expanded', { path: '/' });
 return false;
}
});
// COOKIES
// Header State
    var showTop = $.cookie('showTop');
// Set the user's selection for the Header State
    if (showTop == 'collapsed') {
 $(".documentation").show();
 $(".btn-slide").addClass("active");
};
});
