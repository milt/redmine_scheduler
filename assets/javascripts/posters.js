$(document).ready(function(){

  //default vars
  var untaxed = 1.00;
  var taxed = 1.06;
  var taxScale = taxed;
  var printWidth;
  var printHeight;

  //form settings at load
  var affiliation = $("#poster_affiliation").val();
  var paperType = $("#poster_paper_type").val();
  var paymentType = $("#poster_payment_type").val();

  //get user-configurable variables from redmine


  //functions

  //clear unused/hidden fields
  var clearCheck = function() {
    $("#poster-payment-check input").each(function() {
      $(this).val("");
    });
  };

  var clearBudget = function() {
    $("#poster-payment-budget input").each(function() {
      $(this).val("");
    });
  };
  //handle print size calculation
  var updatePrintAspect = function() {
    printWidth = parseFloat($("#poster_print_width").val());
    printHeight = parseFloat($("#poster_print_height").val());
    var printRatio = printWidth / printHeight;
    //round to 1 decimal place
    printRatio = Math.round(printRatio*10)/10;
    if (printWidth && printHeight){
     $("#print_aspect").val(printRatio);
    }
  };

  //form events
  $("#poster_print_width").change(function(){
    updatePrintAspect();
  });

  $("#poster_print_height").change(function(){
    updatePrintAspect();
  });

  $("#poster_affiliation").change(function(){
    affiliation = $("#poster_affiliation").val();
  });

  $("#poster_paper_type").change(function(){
    paperType = $("#poster_paper_type").val();
  });

  $("#poster_payment_type").change(function(){
    paymentType = $("#poster_payment_type").val();
    switch(paymentType)
    {
    case "jcash":
      clearCheck();
      clearBudget();
      $("#poster-payment-check").hide();
      $("#poster-payment-budget").hide();
      taxScale = taxed;
      break;
    case "check":
      clearBudget();
      $("#poster-payment-check").show();
      $("#poster-payment-budget").hide();
      taxScale = taxed;
      break;
    case "budget":
      clearCheck();
      $("#poster-payment-check").hide();
      $("#poster-payment-budget").show();
      taxScale = untaxed;
      break;
    }
  });

});
