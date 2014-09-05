Silver.Router.reopen({
  location: 'history',
  rootURL: '/backstage/'
});

Silver.Router.map(function() {
  this.resource('movies');
  this.resource('cinemas');
  this.resource('schedules');
});