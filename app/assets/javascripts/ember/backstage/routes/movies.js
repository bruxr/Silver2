Silver.IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('movies')
  }
});

Silver.MoviesRoute = Ember.Route.extend({
  model: function() {
    return this.store.findAll('movie');
  }
});