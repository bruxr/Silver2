Backstage.MoviesRoute = Ember.Route.extend({
  queryParams: {
    show: {
      refreshModel: true
    }
  },
  model: function(params) {
  	return this.store.find('movie', {filter: params.show});
  },
  
  renderTemplate: function(controller, model) {
    this._super();
    this.render('movies-filter', {
      outlet: 'movies-submenu',
      controller: controller
    });
  }
});