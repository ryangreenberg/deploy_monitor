// Typical usage:
// mixin(SomeThing.prototype, withMixin)
function mixin(dest, mixinFn) {
  mixinFn.call(dest);
}

// Objects mixing in withPeriodicUpdates must provide:
//   1. an update method
//   2. an intervalDuration property
// 
// The update method must call this.scheduleNextUpdate
// This responsibility is left to update so that it can decide if it wants
// to schedule the next update immediately, or after an async call has returned
function withPeriodicUpdates() {

  this.startPeriodicUpdates = function() {
    this.periodicUpdatesActive = true;
    this.scheduleNextUpdate();
  };

  // Stop periodic updates. Any scheduled update will be cancelled.
  this.stopPeriodicUpdates = function() {
    this.periodicUpdatesActive = false;
    clearTimeout(this.updateTimeout);
  };

  this.scheduleNextUpdate = function() {
    if (this.periodicUpdatesActive) {
      clearTimeout(this.updateTimeout);
      this.updateTimeout = setTimeout(function(){
        this.updateTimeout = null;
        this.update(this);
      }.bind(this), this.intervalDuration);
    }
  };

  this.isUpdateScheduled = function() {
    return this.updateTimeout !== null;
  };

  // This can be used to backoff or reset the interval
  // It calls the provided function with the current interval duration in ms
  // 
  // If there is an existing scheduled update it will be rescheduled
  this.adjustUpdateInterval = function(adjustmentFn) {
    this.intervalDuration = adjustmentFn(this.intervalDuration);
    if (this.isUpdateScheduled()) {
      scheduleNextUpdate();
    }
  };
}