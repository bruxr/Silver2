Backstage.CinemaController = Ember.ObjectController.extend({
  isEditing: false,
  
  actions: {
    
    edit: function() {
      this.set('isEditing', true);
      $('.movie-popover').animate({scrollTop: 0}, 'fast');
    },
    
    doneEditing: function() {
      var self = this;
      this.get('model').save().then(function() {
        self.set('isEditing', false);
      });
    },
    
    cancelEditing: function() {
      this.set('isEditing', false);
    },
    
    removeSource: function(source) {
      movie = this.get('model');
      movie.get('sources').removeObject(source);
      movie.save();
      source.deleteRecord();
      source.save();
    },
    
    updateScores: function(movie) {
      movie.updateScores();
    },
    
  }
  
});