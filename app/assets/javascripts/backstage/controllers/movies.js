Backstage.MoviesController = Ember.ArrayController.extend({
  queryParams: ['show'],
  show: 'now-showing',
  
  actions: {
    
    merge: function(from, to) {
      var source = this.store.find('movie', from),
          dest = this.store.find('movie', to);
      source.mergeTo(dest);
    }
    
  }
});