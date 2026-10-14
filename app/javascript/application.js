// Application entrypoint for importmap.

// Note: jQuery, jQuery UI, Rails UJS, and all vendor libraries are loaded
// via script tags in the layout before this file runs.

// Initialize all functionality when DOM is ready
$(document).ready(function() {
  // Tips: Initialize qtip tooltips (from tips.js.coffee)
  $("a[title]").qtip({
    style: {
      classes: "ui-tooltip-dark"
    }
  });

  // Staff: Initialize vexflow music notation (from staff.js.coffee)
  $(".staff").vexflow();

  // Search: Initialize autocomplete (from search.js.coffee)
  $("input[data-autocomplete]").each(function() {
    var e = $(this);
    e.autocomplete({
      source: function(request, response) {
        $.getJSON(e.attr("data-autocomplete"), { q: request.term }, function(data) {
          response(data.map(function(i) { return i.name; }));
        });
      }
    });
  });
});
