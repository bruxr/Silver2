Silver.IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('movies')
  }
});

Silver.MoviesRoute = Ember.Route.extend({
  queryParams: {
    filter: { refreshModel: true }
  },
  setupController: function(controller, movies) {
    controller.set('model', movies);
  },
  model: function(params) {
    return this.store.findQuery('movie', params);
  }
});

Silver.MovieRoute = Ember.Route.extend({
  model: function(params) {
    return this.store.find('movie', params.movie_id);
  }
});