$(document).ready(function() {

  // Thread selection  
  // The forum will remember any threads you select for moderating purposes (i.e moderating multiple 
  // threads across many forums) 

  // build an array of any selected threads
  var inline_threads = $.cookie("inline_threads") == null ? '' : $.cookie("inline_threads");
  var inline_array   = inline_threads.substring("1").split("-");
  var inline_total   = inline_threads === "" ? "0" : inline_array.length;

  // highlight and tick the checkbox of any selected threads
  if (inline_threads) {
    for (id in inline_array) {
      $("#thread_line_" + inline_array[id] + " td").toggleClass("inlinemod");
      $("#tlist_" + inline_array[id]).attr("checked", true);
    }
    // update the number of total topics selected
    $("#inlinego").attr("value", "Go (" + inline_total + ")");
  }

  // toogle thread selection
  $(".inline_mod").click(function() {
      var thread_id      = $(this).attr("id").replace("tlist_", "");
      var cookie_value   = $.cookie("inline_threads") == null ? '' : $.cookie("inline_threads");
      var cookie_array   = cookie_value.substring("1").split("-");
      var total_selected = cookie_value === "" ? 0 : cookie_array.length
      
      // save the selection data in a cookie named "inline_threads"
      if ($(this).attr('checked') == "checked") {
          $("#thread_line_" + thread_id + " td").toggleClass("inlinemod");
          $("#inlinego").attr("value", "Go (" + (total_selected + 1) + ")");
          $.cookie("inline_threads", cookie_value + "-" + thread_id);
      } 
      else {
          $("#thread_line_" + thread_id + " td").toggleClass("inlinemod");
          $("#inlinego").attr("value", "Go (" + (total_selected - 1) + ")");
          $.cookie("inline_threads", cookie_value.replace("-" + thread_id, ""));
      }
  });
    

  // $(".inline_mod").click(function() {
  //   var length, selection, thread_id, total_sel;
  //   thread_id = $(this).attr("id").replace("tlist_", "");
  //   selection = (!($.cookie("inline_threads") != null) ? "" : $.cookie("inline_threads"));
  //   length = (inline_threads === "" ? "0" : inline_array.length);
  //   $.cookie("inline_threads").substring("1").split("-").length;
  //   total_sel = $.cookie("inline_threads").substring("1").split("-").length;
  //   if ($(this).attr("checked") === "checked") {
  //     $("#thread_line_" + thread_id + " td").toggleClass("inlinemod");
  //     $.cookie("inline_threads", selection + "-" + thread_id);
  //     return $("#inlinego").attr("value", "Go (" + (total_sel + 1) + ")");
  //   } else {
  //     $("#thread_line_" + thread_id + " td").toggleClass("inlinemod");
  //     $.cookie("inline_threads", selection.replace("-" + thread_id, ""));
  //     return $("#inlinego").attr("value", "Go (" + (total_sel - 1) + ")");
  //   }
  // });
});
