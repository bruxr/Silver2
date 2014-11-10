Backstage.SchedulesRoute = Ember.Route.extend({
  model: function(params) {
  	return this.store.find('schedule');
  }
});