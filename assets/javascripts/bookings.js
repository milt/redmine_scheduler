var bindTimeslotCheckbox = (function() {
  $('.timeslot_checkbox').on("mouseover", function() {
    var id = $(this).attr('value');

    $.ajax({
      url: "/timeslots/" + id,
      type: "get",
      success: function(data) {
          $("#timeslot").html(data)
      }
    });
  });
});

$(document).ready(function(){
  // var liveSearch = (function() {
  //   $.get($(this).attr("action"), $(this).serialize(), null, "script");
  //   return false;
  // });

  // liveSearch();
  // $("#things-search").ready(liveSearch);
  // $("#q_name_cont").bind("keyup", liveSearch);
  // bindTimeslotCheckbox();

});
