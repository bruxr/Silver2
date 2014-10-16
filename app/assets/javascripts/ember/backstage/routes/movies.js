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
    //return this.store.findAll('movie', {type: 'now_showing'});
    return this.store.filter('movie', {filter: 'now-showing'}, function(movie) {
      true // API does it for us
    });
  }
});