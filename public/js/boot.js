var app = {};

app.clock = new Clock($(document));
app.clock.start();

app.timeDisplay = new TimeDisplay($(document));
app.timeDisplay.start();