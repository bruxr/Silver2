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
    return this.store.findAll('movie');
  }
});