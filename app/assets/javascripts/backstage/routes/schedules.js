Backstage.SchedulesRoute = Ember.Route.extend({
  
  model: function(params) {
  	return this.store.find('schedule');
  },
  
  afterModel: function() {
    var self = this;
    return new Promise(function(resolve, reject) {
      $.when(
        $.getJSON('/api/movies?type=list', function(resp) {
          self.set('movies', resp.movies);
        }),
        $.getJSON('/api/cinemas?type=list', function(resp) {
          self.set('cinemas', resp.cinemas);
        })
      ).then(resolve);
    });
  },
  
  setupController: function(controller, model) {
    controller.set('movies', this.get('movies'));
    controller.set('cinemas', this.get('cinemas'));
    this._super(controller, model);
  }
  
});