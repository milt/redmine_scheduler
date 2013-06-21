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


$(document).ready(function(){

});
