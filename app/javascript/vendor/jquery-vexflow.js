// jquery.vexflow.js
// Copyright Ben Hughes
// https://github.com/rubiety/jquery-vexflow

(function($) {

  // When called on an element, will replace the contents of that element with 
  // a rendered-out staff using VexFlow and vexflow-json.
  // 
  // Accepts a vexflow-json data object.
  //
  // data - An object of vexflow-json data.
  //
  // Returns the jQuery object
  $.fn.vexflow = function(data, render_options) {
    return this.each(function() {
      $.vexflow(this, data, render_options);
    });
  };
  
  $.vexflow = function(element, data, render_options) {
    if (!Vex.Flow.JSON) {
      throw "Must require vexflow-json before using this.";
      return false;
    }

    // If we have a data-staff attribute and passed data is undefined, use it!
    if (!data && $(element).attr("data-staff")) { data = JSON.parse($(element).attr("data-staff")); }

    if (!render_options) { render_options = {}; }
    if (!render_options.width) { render_options.width = $(element).attr("data-width") || $(element).attr("width") || 600; }
    if (!render_options.height) { render_options.height = $(element).attr("data-height") || $(element).attr("height") || 110; }
    if (!render_options.scale) { render_options.scale = parseFloat($(element).attr("data-scale") || "1"); }
    if (!render_options.clef && $(element).attr("data-clef")) { render_options.clef = $(element).attr("data-clef").split(","); }

    var canvas_element = $("<canvas width='" + render_options.width + "' height='" + render_options.height + "'></canvas>");
    canvas_element.appendTo(element)
    
    return (new Vex.Flow.JSON(data)).render(canvas_element[0], render_options);
  };

})(jQuery);
