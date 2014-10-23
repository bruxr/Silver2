Backstage.MovieController = Ember.ObjectController.extend({
  trailerUrl: function() {
    var trailer = this.get('model.trailer');
    return 'http://www.youtube.com/embed/%s?controls=0&amp;disablekb=1&amp;iv_load_policy=3&amp;modestbranding=1&amp;rel=0&amp;showinfo=0'.replace('%s', trailer);
  }.property('model.trailer')
});