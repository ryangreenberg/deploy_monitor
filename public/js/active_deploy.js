function ActiveDeploy ($node) {
  this.$node = $node;
  this.intervalDuration = 5000;
}
mixin(ActiveDeploy.prototype, withPeriodicUpdates);

ActiveDeploy.prototype.update = function() {
  var lastUpdatedAt = this.getUpdatedAt();
  var deployId = this.getDeployId();

  var request = $.ajax({
    dataType: 'json',
    data: {updated_at: lastUpdatedAt, id: deployId},
    url: '/active_deploy'
  });

  request.done(this.display.bind(this));
  request.complete(this.scheduleNextUpdate.bind(this));
};

ActiveDeploy.prototype.display = function(rsp) {
  this.setUpdatedAt(rsp.updated_at);

  if (rsp.progress_percentage) {
    this.$node.find('.deploy-progress .bar').css('width', rsp.progress_percentage + "%");
  }

  if (rsp.current_progress) {
    this.$node.find('.current-progress').text(rsp.current_progress);
  }

  if (rsp.deploy_steps) {
    var deployStepsHtml = rsp.deploy_steps.map(function(step){ return step.html; }).join("");
    this.$node.find('.steps').html(deployStepsHtml);
  }

  if (rsp.deploy_overview) {
    this.$node.find('.deploy-overview').html(rsp.deploy_overview);
    this.stopPeriodicUpdates();
  }
};

ActiveDeploy.prototype.getDeployId = function() {
  return this.$node.attr('data-deploy-id');
};

ActiveDeploy.prototype.getUpdatedAt = function() {
  return this.$node.attr('data-updated-at');
};

ActiveDeploy.prototype.setUpdatedAt = function(timestamp) {
  return this.$node.attr('data-updated-at', timestamp);
};
