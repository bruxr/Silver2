Backstage.Router.reopen({
  location: 'history',
  rootURL: '/backstage/'
});

Backstage.Router.map(function() {
  this.resource('movies', function() {
    this.resource('movie', { path: '/:movie_id' });
  });
  this.resource('cinemas');
  this.resource('schedules');
});