Backstage.MovieRoute = Ember.Route.extend({
  
  model: function(params) {
  	return this.store.find('movie', params.id);
  },
  
  setupController: function(controller, model) {
    if (model.get('partial') === true) {
      model.reload();
    }
    controller.set('model', model)
  },
  
  actions: {
    
    // Invoked when the slidein modal is closed
    // e.g. clicking the curtains
    close: function() {
      if (this.get('controller').get('isEditing') === true) {
        return;
      }
      else {
        this.transitionTo('movies');
      }
    }
    
  }
});