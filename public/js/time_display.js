(function(exports) {

  function TimeDisplay ($node) {
    this.$node = $node;
  }

  TimeDisplay.prototype.start = function() {
    $(this.$node).bind('tick', this.updateTimes.bind(this));
  };

  TimeDisplay.prototype.updateTimes = function() {
    var now = Math.floor(new Date().getTime() / 1000);
    this.$node.find('.timer').each(function () {
      var $this = $(this);
      var timestamp = $this.attr('data-timestamp');
      var formatStr = $this.attr('data-format') || "%M:%S";
      $(this).text(formatDuration(formatStr, now - timestamp));
    });
  };

  function formatDuration (formatStr, secs) {
    var h = Math.floor(secs / 3600);
    var m = Math.floor((secs - (h * 3600)) / 60);
    var s = secs - (h * 3600) - (m * 60);

    return formatStr
      .replace(/%H/, padWithZeros(h, 2))
      .replace(/%M/, padWithZeros(m, 2))
      .replace(/%S/, padWithZeros(s, 2))
      .replace(/%h/, h)
      .replace(/%m/, m)
      .replace(/%s/, s);
  }

  function padWithZeros(n, digits) {
    n += '';
    while (n.length < digits) {
      n = '0' + n;
    }
    return n;
  }

  exports.TimeDisplay = TimeDisplay;

}(window));