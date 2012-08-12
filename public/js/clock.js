function Clock ($node) {
  this.$node = $node;
}

Clock.prototype.start = function() {
  var now = new Date().getTime();
  var msUntilNextSecond = (now / 1000) % 1 * 1000;
  setTimeout(function() {
    this.interval = setInterval(this.tick.bind(this), 1000);
  }.bind(this), msUntilNextSecond);
};

Clock.prototype.stop = function() {
  clearInterval(this.interval);
};

Clock.prototype.tick = function() {
  this.$node.trigger('tick');
};
