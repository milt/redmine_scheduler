$(document).ready(function(){

  //handle document size calculation
  var updateDocAspect = function() {
    var docWidth = parseFloat($("#poster_doc_width").val());
    var docHeight = parseFloat($("#poster_doc_height").val());
    var docRatio = docWidth / docHeight;
    //round to 1 decimal place
    docRatio = Math.round(docRatio*10)/10;
    if (docWidth && docHeight){
     $("#doc_aspect").val(docRatio);
    }
  };

  $("#poster_doc_width").change(function(){
    updateDocAspect();
  });

  $("#poster_doc_height").change(function(){
    updateDocAspect();
  });

  //handle print size calculation
  var updatePrintAspect = function() {
    var printWidth = parseFloat($("#poster_print_width").val());
    var printHeight = parseFloat($("#poster_print_height").val());
    var printRatio = printWidth / printHeight;
    //round to 1 decimal place
    printRatio = Math.round(printRatio*10)/10;
    if (printWidth && printHeight){
     $("#print_aspect").val(printRatio);
    }
  };

  $("#poster_print_width").change(function(){
    updatePrintAspect();
  });

  $("#poster_print_height").change(function(){
    updatePrintAspect();
  });

  

  $("#poster_affiliation").change(function(){
    // alert( "Handler for .change() called." );
  });

  $("#poster_paper_type").change(function(){
    // alert( "Handler for .change() called." );
  });

  $("#poster_payment_type").change(function(){
    switch($(this).val())
    {
    case "jcash":
      $("#poster-payment-check").hide();
      $("#poster-payment-budget").hide();
      break;
    case "check":
      $("#poster-payment-check").show();
      $("#poster-payment-budget").hide();
      break;
    case "budget":
      $("#poster-payment-check").hide();
      $("#poster-payment-budget").show();
      break;
    }
  });

});
