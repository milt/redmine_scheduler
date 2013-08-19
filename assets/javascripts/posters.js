$(document).ready(function(){
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