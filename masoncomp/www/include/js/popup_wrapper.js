$(document).ready(tipUpdate);
function tipUpdate() {
    var distance = 10;
    var time = 250;
    var hideDelay = 500;
    var hideDelayTimer = null;
    var beingShown = false;
    var shown = false;
    var idCheck = null;

   $("area.jTip")
   .mouseover(function () {
      if (hideDelayTimer) clearTimeout(hideDelayTimer);
      if ((beingShown || shown) && idCheck == this.id) {
        return;
      } else {
        $('#JT').remove(); 
        idCheck = this.id;
        beingShown = true;
      if($.browser.msie){
        JT_IE_area_show(this.href,this.id,this.title,this.coords,'workflow');
      } else {
        JT_area_show(this.href,this.id,this.alt,this.coords);
      }
        beingShown = false;
        shown = true;
      }
    })
    .mouseout(function () {
      if (hideDelayTimer) clearTimeout(hideDelayTimer);
      hideDelayTimer = setTimeout(function () {
        hideDelayTimer = null;
        shown = false;
        $('#JT').remove(); 
      }, hideDelay);
    })


   $('a.jTip')
   .mouseover(function () {
      if (hideDelayTimer) clearTimeout(hideDelayTimer);
      if ((beingShown || shown) && idCheck == this.id) {
        return;
      } else {
        $('#JT').remove();
        idCheck = this.id;
        beingShown = true;
        JT_show(this.href,this.id,this.name);
        beingShown = false;
        shown = true;
      }
    })
    .mouseout(function () {
      if (hideDelayTimer) clearTimeout(hideDelayTimer);
      hideDelayTimer = setTimeout(function () {
        hideDelayTimer = null;
        shown = false;
        $('#JT').remove();
      }, hideDelay);
    })

   $('div#JT').livequery(function(){

   $(this).mouseover(function () {
      if (hideDelayTimer) clearTimeout(hideDelayTimer);
      if (beingShown || shown) {
        return;
      } else {
        beingShown = true;
//        JT_show(this.href,this.id,this.name);
        beingShown = false;
        shown = true;
      }
    })
    $(this).mouseout(function () {
      if (hideDelayTimer) clearTimeout(hideDelayTimer);
      hideDelayTimer = setTimeout(function () {
        hideDelayTimer = null;
        shown = false;
        $('#JT').remove();
      }, hideDelay);
    });
   });

}

