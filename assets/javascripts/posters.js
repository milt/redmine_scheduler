$(document).ready(function(){

  //get user-configurable variables from redmine
  var posterSettings;
  $.getJSON( "/poster_settings", function( json ) {
    posterSettings = json;
  });

  //default vars
  var untaxed = 1.00;
  var taxed = 1.06;
  var taxScale = taxed;
  var printWidth;
  var printHeight;
  var printRatio;
  var border;
  var quantity;
  var minDeposit;
  var paperCost = 3.50;
  var total;
  var serviceCharge = 10.00;


  //get settings at load so things work on rails validation errors.
  var affiliation = $("#poster_affiliation").val();
  var paperType = $("#poster_paper_type").val();
  var paymentType = $("#poster_payment_type").val();

  //get dimensions to handle reload for validation error
  if ($("#poster_print_width").val() != "") { printWidth = parseFloat($("#poster_print_width").val()); }
  if ($("#poster_print_height").val() != "") { printHeight = parseFloat($("#poster_print_height").val()); }
  if ($("#poster_print_border").val() != "") { border = parseFloat($("#poster_print_border").val()); }
  if ($("#poster_quantity").val() != "") { quantity = parseInt($("#poster_quantity").val()); }



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
    printRatio = printWidth / printHeight;
    //round to 1 decimal place
    printRatio = Math.round(printRatio*10)/10;
    if (printWidth && printHeight){
     $("#print_aspect").val(printRatio);
    }
  };

  //display paper cost
  var updateCost = function() {
    switch(paperType)
    {
      case "matte":
        switch(affiliation)
        {
          case "student":
            paperCost = posterSettings.poster_matte_student;
            break;
          case "staff":
            paperCost = posterSettings.poster_matte_staff;
            break;
          case "dmc":
            paperCost = posterSettings.poster_matte_dmc;
            break;
        }
        break;
      case "glossy":
        switch(affiliation)
        {
          case "student":
            paperCost = posterSettings.poster_glossy_student;
            break;
          case "staff":
            paperCost = posterSettings.poster_glossy_staff;
            break;
          case "dmc":
            paperCost = posterSettings.poster_glossy_dmc;
            break;
        }
        break;
    }
    $("#paper_cost").val(paperCost);
  };

  var updateMinDeposit = function() {
    if ( paymentType == "budget" ) {
      minDeposit = total;
    } else {
      minDeposit = (total/2).toFixed(2);
    }
    $("#minimum_deposit").val(minDeposit);
  };

  var updateTotal = function() {
    if ((quantity > 0) && printWidth && printHeight && paperCost) {
      total = (taxScale)*( ((printWidth)*(printHeight)/144)*(paperCost)*(quantity) + serviceCharge) //+ ((2)*(quantity - 1)); // the hell is that?!?!
      total = total.toFixed(2);
      $("#poster_total").val(total);
      updateMinDeposit();
    }
  };


  if ($("#poster_total").val() != "") {
    total = parseFloat($("#poster_total").val()).toFixed(2);
    updateMinDeposit();
  }

  if ($("#poster_deposit").val() != "") {
    $("#balance_due").val((total - $("#poster_deposit").val()).toFixed(2));
  }


  //form events
  $("#poster_print_width").change(function() {
    printWidth = parseFloat($(this).val());
    updatePrintAspect();
    updateTotal();
  });

  $("#poster_print_height").change(function() {
    printHeight = parseFloat($(this).val());
    updatePrintAspect();
    updateTotal();
  });

  $("#poster_border").change(function() {
    border = parseFloat($(this).val());
    updateTotal();
  });

  $("#poster_affiliation").change(function(){
    affiliation = $(this).val();
    if ( affiliation == "dmc" ) {
      serviceCharge = 0.00;
    } else {
      serviceCharge = 10.00;
    }
    updateCost();
    updateTotal();
  });

  $("#poster_paper_type").change(function(){
    paperType = $(this).val();
    updateCost();
    updateTotal();
  });

  $("#poster_quantity").change(function() {
    quantity = parseInt($(this).val());
    updateTotal();
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
    updateTotal();
  });

  $("#poster_deposit").change(function() {
    $("#balance_due").val((total - $(this).val()).toFixed(2));
  });

});
