function App () {
}

App.prototype.boot = function() {
  this.clock = new Clock($(document));
  this.clock.start();

  this.timeDisplay = new TimeDisplay($(document));
  this.timeDisplay.start();

  $(this.bootDomReady.bind(this));
};

App.prototype.bootDomReady = function() {
  this.activeDeploys = new ActiveDeploys($('.active-deploys'));
  this.activeDeploys.startPeriodicUpdates();
  this.recentDeploys = new RecentDeploys($('.recent-deploys'));
  this.recentDeploys.startPeriodicUpdates();
};

var app = new App();
app.boot();

