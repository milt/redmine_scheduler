$(document).ready(function(){
   $("tr.fine-table-row").click(function(){
      /* personally I would throw a url attribute (<tr url="http://www.hunterconcepts.com">) on the tr and pull it off on click */
      window.location = $(this).attr("url");

   });
});