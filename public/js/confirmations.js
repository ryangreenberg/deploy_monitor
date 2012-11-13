function Confirmations ($node) {
  this.$node = $node;
  $node.on('click', '[data-confirm]', this.confirm);
}

Confirmations.prototype.confirm = function(event) {
  var $ele = $(event.target);
  var warningMessage = $ele.attr('data-confirm');
  if (!confirm(warningMessage)) {
    return false;
  }
};
