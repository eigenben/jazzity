// Application entrypoint for importmap.

// Note: jQuery, jQuery UI, Rails UJS, and all vendor libraries are loaded
// via script tags in the layout before this file runs.

// Global Jazzity namespace and utilities (from global.js.coffee)
window.Jazzity = window.Jazzity || {};

Jazzity.signed_in = function() {
  return $("header#header aside[data-current-musician-id]").length > 0;
};

Jazzity.current_musician_id = function() {
  return parseInt($("header#header aside[data-current-musician-id]").attr("data-current-musician-id"));
};

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
          response.call(null, _.map(data, function(i) { return i.name; }));
        });
      }
    });
  });

  // Facebook: Invite friends functionality (from facebook.js.coffee)
  $("a.invite-facebook-friends").click(function() {
    FB.init({
      appId: $(this).data("app-id"),
      cookie: true,
      status: true,
      xfbml: true,
      oauth: true
    });

    FB.ui({ method: "apprequests", message: "Wants you to join Jazzity, the jazz knowledge engine!" });
    return false;
  });
});
