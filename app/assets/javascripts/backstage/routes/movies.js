Backstage.MoviesRoute = Ember.Route.extend({
  model: function(params) {
  	return this.store.findAll('movie')
  },
  renderTemplate: function() {
    this.render('movies-filter', {
      outlet: 'toolbars'
    });
  }
});