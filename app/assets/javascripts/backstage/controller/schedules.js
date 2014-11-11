Backstage.SchedulesController = Ember.ArrayController.extend({
  
  x: function() {
    return this.get('router');
  }.property('router'),
  
  cinemas: function() {
    return this.get('router').get('cinemas');
  }.property('router'),
  
  movies: function() {
    return this.get('router').get('movies');
  }.property('router')
  
});