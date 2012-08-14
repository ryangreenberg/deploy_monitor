function RecentDeploys ($node) {
  this.$node = $node;
  this.intervalDuration = 10000;
}

RecentDeploys.prototype.startPeriodicUpdates = function() {
  this.scheduleNextUpdate();
};

RecentDeploys.prototype.stopPeriodicUpdates = function() {
  clearTimeout(this.updateTimeout);
};

RecentDeploys.prototype.scheduleNextUpdate = function() {
  this.updateTimeout = setTimeout(this.update.bind(this), this.intervalDuration);
};

RecentDeploys.prototype.update = function() {
  var lastUpdatedAt = this.getUpdatedAt();

  var request = $.ajax({
    dataType: 'json',
    data: {updated_at: lastUpdatedAt},
    url: '/recent_deploys'
  });

  request.done(this.display.bind(this));
  request.complete(this.scheduleNextUpdate.bind(this));
};

RecentDeploys.prototype.display = function(rsp) {
  this.setUpdatedAt(rsp.updated_at);
  if (rsp.deploy_html.length) {
    var deploy_html = rsp.deploy_html;
    this.$node.find('tbody').prepend(deploy_html);
  }
};

RecentDeploys.prototype.getUpdatedAt = function() {
  return this.$node.attr('data-updated-at');
};

RecentDeploys.prototype.setUpdatedAt = function(timestamp) {
  return this.$node.attr('data-updated-at', timestamp);
};
