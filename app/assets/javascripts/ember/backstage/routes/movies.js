Silver.IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('movies')
  }
});

Silver.MoviesRoute = Ember.Route.extend({
  setupController: function(controller, movies) {
    controller.set('model', movies);
  },
  model: function() {
    return this.store.filter('movie', {filter: 'now-showing'}, function(movie) {
      return true; // API does this for us.
    });
  }
});