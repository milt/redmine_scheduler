var bindTimeslotCheckbox = (function() {
  $('.timeslot_checkbox').on("mouseover", function() {
    $("#coach_name").html("<h2>" + $(this).attr('data-coach-name') + "</h2>");
    $("#time").html("<h3>" + $(this).attr('data-time') + "</h3>");
    var skills = $(this).attr('data-coach-skills').split(',')

    $("#skills_list").empty();
    $("#auths_list").empty();
    
    if (skills != "") {
      skills.map( function(item) {
        $("#skills_list").append("<li>" + item + "</li>")
      });
    }

    var auths = $(this).attr('data-coach-auths').split(',')

    if (auths != "") {
      auths.map( function(item) {
        $("#auths_list").append("<li>" + item + "</li>")
      });
    }
  });
});

var limitToShift = (function() {
  $(".timeslot_checkbox").on("click", function() {
    var shiftCLass;
    var classList = this.className.split(/\s+/);
    for (var i = 0; i < classList.length; i++) {
       if (classList[i].indexOf("shift_") != -1) {
         shiftClass = "." + classList[i];
       }
    }
    if ($(shiftClass + ":checked").not(this).length == 0)
    {
      $(".timeslot_checkbox").not($(shiftClass)).attr('disabled', this.checked);
      // force closed timeslots disabled
      $(".timeslot_checkbox.closed").attr("disabled", true);
    }

  });
});


$(document).ready(function(){

});
