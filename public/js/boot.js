function App () {
}

App.prototype.boot = function() {
  this.clock = new Clock($(document));
  this.clock.start();

  this.timeDisplay = new TimeDisplay($(document));
  this.timeDisplay.start();

  this.confirmations = new Confirmations($(document));

  $(this.bootDomReady.bind(this));
};

App.prototype.bootDomReady = function() {
  if ($('.active-deploys').length) {
    this.activeDeploys = new ActiveDeploys($('.active-deploys'));
    this.activeDeploys.startPeriodicUpdates();
  }

  if ($('.recent-deploys').length) {
    this.recentDeploys = new RecentDeploys($('.recent-deploys'));
    this.recentDeploys.startPeriodicUpdates();
  }

  if ($('.deploy.active').length) {
    this.activeDeploy = new ActiveDeploy($('.deploy.active'));
    this.activeDeploy.startPeriodicUpdates();
  }

  this.timeDisplay.makeTimesLocal();
};

var app = new App();
app.boot();
