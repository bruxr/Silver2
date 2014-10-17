Backstage.IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('movies')
  }
});

Backstage.MoviesRoute = Ember.Route.extend({
  model: function(params) {
  	return this.store.findAll('movie')
  }
});