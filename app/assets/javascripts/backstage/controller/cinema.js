Backstage.CinemaController = Ember.ObjectController.extend({
  isEditing: false,
  
  statuses: ['active', 'hidden', 'disabled'],
  
  actions: {
    
    edit: function() {
      this.set('isEditing', true);
      $('.paper').animate({scrollTop: 0}, 'fast');
    },
    
    doneEditing: function() {
      var self = this;
      this.get('model').save().then(function() {
        self.set('isEditing', false);
      });
    },
    
    cancelEditing: function() {
      this.set('isEditing', false);
    }
    
  }
  
});