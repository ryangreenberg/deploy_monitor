var app = {};

app.clock = new Clock($(document));
app.clock.start();

$(document).bind('tick', function () {
  var now = Math.floor(new Date().getTime() / 1000);
  $('.timer').each(function () {
    var $this = $(this);
    var timestamp = $this.attr('data-timestamp');
    var formatStr = $this.attr('data-format');
    $(this).text(formatDuration("%M:%S", now - timestamp));
  });
});

function formatDuration (formatStr, secs) {
  var h = Math.floor(secs / 3600);
  var m = Math.floor((secs - (h * 3600)) / 60);
  var s = secs - (h * 3600) - (m * 60);

  return formatStr.replace(/%H/, h).replace(/%M/, m).replace(/%S/, zeroPad(s, 2));
}

// Pad a number with leading zeros until it is digits long
var zeroPad = function(n, digits) {
    n += '';
    while (n.length < digits) {
        n = '0' + n;
    }
    return n;
};