Backstage.MoviesRoute = Ember.Route.extend({
  queryParams: {
    show: {
      refreshModel: true
    }
  },
  model: function(params) {
  	return this.store.find('movie', {filter: params.show});
  }
});