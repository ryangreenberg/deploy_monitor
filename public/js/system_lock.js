function SystemLock ($node) {
  this.$node = $node;
  $node.on('click', '.action-lock', this.lock.bind(this));
  $node.on('click', '.action-unlock', this.unlock.bind(this));
  $node.on('mouseenter', this.addHoverClasses.bind(this));
  $node.on('mouseleave', this.removeHoverClasses.bind(this));
}

SystemLock.prototype.lock = function() {
  var lockMessage = prompt("Why are deploys for this system locked?");
  if (lockMessage) {
    this.$node.addClass('locked').removeClass('unlocked');
    var request = $.ajax({
      dataType: 'json',
      data: {updated_at: lastUpdatedAt, id: deployId},
      url: '/active_deploy'
    });

    request.done(this.display.bind(this));
    request.complete(this.scheduleNextUpdate.bind(this));
  }
};

SystemLock.prototype.unlock = function() {
  var unlockSystem = confirm("Are you sure you want to allow deploys for this system?");
  if (unlockSystem) {
    this.$node.addClass('unlocked').removeClass('locked');
  }
};

SystemLock.prototype.addHoverClasses = function() {
  var $button = this.$node.find('button');
  if (this.$node.hasClass('locked')) {
    $button.removeClass('btn-danger');
  }
};

SystemLock.prototype.removeHoverClasses = function() {
  var $button = this.$node.find('button');
  if (this.$node.hasClass('locked')) {
    $button.addClass('btn-danger');
  }
};
// 
// 
// ActiveDeploy.prototype.update = function() {
//   var lastUpdatedAt = this.getUpdatedAt();
//   var deployId = this.getDeployId();
// 
//   var request = $.ajax({
//     dataType: 'json',
//     data: {updated_at: lastUpdatedAt, id: deployId},
//     url: '/active_deploy'
//   });
// 
//   request.done(this.display.bind(this));
//   request.complete(this.scheduleNextUpdate.bind(this));
// };
// 
// ActiveDeploy.prototype.display = function(rsp) {
//   this.setUpdatedAt(rsp.updated_at);
// 
//   if (rsp.progress_percentage) {
//     this.$node.find('.deploy-progress .bar').css('width', rsp.progress_percentage + "%");
//   }
// 
//   if (rsp.current_progress) {
//     this.$node.find('.current-progress').text(rsp.current_progress);
//   }
// 
//   if (rsp.deploy_steps) {
//     var deployStepsHtml = rsp.deploy_steps.map(function(step){ return step.html; }).join("");
//     this.$node.find('.steps').html(deployStepsHtml);
//   }
// 
//   if (rsp.deploy_overview) {
//     this.$node.find('.deploy-overview').html(rsp.deploy_overview);
//     this.stopPeriodicUpdates();
//   }
// };
// 
// ActiveDeploy.prototype.getDeployId = function() {
//   return this.$node.attr('data-deploy-id');
// };
// 
// ActiveDeploy.prototype.getUpdatedAt = function() {
//   return this.$node.attr('data-updated-at');
// };
// 
// ActiveDeploy.prototype.setUpdatedAt = function(timestamp) {
//   return this.$node.attr('data-updated-at', timestamp);
// };
