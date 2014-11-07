Backstage.Router.reopen({
  location: 'history',
  rootURL: '/backstage/'
});

Backstage.Router.map(function() {
  this.route('movies', function() {
    this.resource('movie', { path: '/:id' });
  });
  this.route('cinemas', function() {
    this.resource('cinema', { path: '/:id' });
  });
  this.resource('schedules');
});