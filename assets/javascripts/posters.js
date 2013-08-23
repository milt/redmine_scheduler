$(document).ready(function(){

  //default vars
  var untaxed = 1.00;
  var taxed = 1.06;
  var taxScale;
  var printWidth;
  var printHeight;
  var printRatio;
  var border;
  var quantity;
  var minDeposit;
  var paperCost;
  var total;
  var serviceCharge = 10.00;
  var deposit;
  var posterSettings;
  var affiliation;
  var paperType;
  var paymentType;

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
    if (paperType && affiliation && posterSettings) {
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
      if ( affiliation == "dmc" ) {
        serviceCharge = 0.00;
      } else {
        serviceCharge = 10.00;
      }
      $("#paper_cost").val(paperCost);
    }
  };

  var checkSufficientDeposit = function() {
    if (minDeposit && deposit) {
      if (minDeposit > deposit) {
        $("#poster_deposit").css("background-color", "red");
      } else {
        $("#poster_deposit").css("background-color", "green");
      }
    }
  };

  var updateMinDeposit = function() {
    if (paymentType && total) {
      if ( paymentType == "budget" ) {
        minDeposit = total;
      } else {
        minDeposit = (total/2).toFixed(2);
      }
    }
    $("#minimum_deposit").val(minDeposit);
    checkSufficientDeposit();
  };

  var updatePayment = function() {
    if (paymentType) {
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
    }
  };

  var updateBalanceDue = function() {
    if (total && deposit) {
      $("#balance_due").val((total - deposit).toFixed(2));
    }
  };



  var updateTotal = function() {
    if ((quantity > 0) && printWidth && printHeight && paperCost && taxScale) {
      total = (taxScale)*( ((printWidth)*(printHeight)/144)*(paperCost)*(quantity) + serviceCharge) //+ ((2)*(quantity - 1)); // the hell is that?!?!
      total = total.toFixed(2);
      $("#poster_total").val(total);

      updateMinDeposit();
      updateBalanceDue();
      checkSufficientDeposit();
    }
  };

  //get user-configurable variables from redmine

  $.getJSON( "/poster_settings", function( json ) {
    posterSettings = json;

    //stuff to do after getting JSON data

    //get settings at ready so things work on rails validation errors.
    affiliation = $("#poster_affiliation").val();
    paperType = $("#poster_paper_type").val();
    paymentType = $("#poster_payment_type").val();




    //get dimensions to handle reload for validation error
    if ($("#poster_print_width").val() != "") { printWidth = parseFloat($("#poster_print_width").val()); }
    if ($("#poster_print_height").val() != "") { printHeight = parseFloat($("#poster_print_height").val()); }
    if ($("#poster_print_border").val() != "") { border = parseFloat($("#poster_print_border").val()); }
    if ($("#poster_quantity").val() != "") { quantity = parseInt($("#poster_quantity").val()); }


    //set cost and form elements
    updatePrintAspect();
    updatePayment();
    updateCost();

    if ($("#poster_total").val() != "") {
      total = parseFloat($("#poster_total").val()).toFixed(2);
    }

    if ($("#poster_deposit").val() != "") {
      deposit = parseFloat($("#poster_deposit").val()).toFixed(2);
    }
    updateMinDeposit();
    updateBalanceDue();
  });



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
    paymentType = $(this).val();
    updatePayment();
    updateTotal();
  });

  $("#poster_deposit").change(function() {
    deposit = parseFloat($(this).val()).toFixed(2);
    checkSufficientDeposit();
    updateBalanceDue();
  });
});
