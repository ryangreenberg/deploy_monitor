function ActiveDeploys ($node) {
  this.$node = $node;
  this.intervalDuration = 10000;
}

ActiveDeploys.prototype.startPeriodicUpdates = function() {
  this.scheduleNextUpdate();
};

ActiveDeploys.prototype.stopPeriodicUpdates = function() {
  clearTimeout(this.updateTimeout);
};

ActiveDeploys.prototype.scheduleNextUpdate = function() {
  this.updateTimeout = setTimeout(this.update.bind(this), this.intervalDuration);
};

ActiveDeploys.prototype.update = function() {
  var lastUpdatedAt = this.getUpdatedAt();

  var request = $.ajax({
    dataType: 'json',
    data: {updated_at: lastUpdatedAt},
    url: '/active_deploys'
  });

  request.done(this.display.bind(this));
  request.complete(this.scheduleNextUpdate.bind(this));
};

ActiveDeploys.prototype.display = function(rsp) {
  this.setUpdatedAt(rsp.updated_at);
  if (rsp.new_deploys.length) {
    var newDeploysHtml = rsp.new_deploys.map(function(deploy){ return deploy.html; });
    this.$node.find('.deploy-list').prepend(newDeploysHtml);
    this.$node.find('.no-active-deploys').hide();
  }

  if (rsp.completed_deploys.length) {
    var completedDeploys = rsp.completed_deploys;
    for (var i=0; i < completedDeploys.length; i++) {
      var deployId = completedDeploys[i].id;
      this.$node.find('[data-deploy-id=' + deployId + ']').remove();
    }
    if (!this.$node.find('.active-deploy').length) {
      this.$node.find('.no-active-deploys').show();
    }
  }

  if (rsp.continuing_deploys.length) {
    var continuingDeploys = rsp.continuing_deploys;
    for (var i=0; i < continuingDeploys.length; i++) {
      var deploy = continuingDeploys[i],
        deployId = deploy.id,
        currentProgress = deploy.current_progress,
        progressPercentage = deploy.progress_percentage;

      var $deploy = this.$node.find('[data-deploy-id=' + deployId + ']');
      $deploy.find('.current-progress').text(currentProgress);
      $deploy.find('.bar').css('width', progressPercentage + '%');
    }
  }
};

ActiveDeploys.prototype.getUpdatedAt = function() {
  return this.$node.attr('data-updated-at');
};

ActiveDeploys.prototype.setUpdatedAt = function(timestamp) {
  return this.$node.attr('data-updated-at', timestamp);
};
