Backstage.MoviesView = Ember.View.extend({
  name: 'movies',
  templateName: 'movies',
  
  draggedMovie: null,

  setupDragDropMerge: function() {
    var self = this;
    $('.movie .thumbnail').tooltip({
      title: function() { return 'Merge to '+ $(this).data('title') },
      trigger: 'manual'
    })
    .on('dragstart', function(evt) {
      self.draggedMovie = $(this);
      evt.dataTransfer.effectAllowed = 'move'
      evt.dataTransfer.dropEffect = 'move'
    })
    .on('dragenter', function(evt) {
      var el = $(this);
      if  (el.is('a')) el = el.find('.thumbnail');
      if (!el.is(self.draggedMovie)) {
        el.addClass('over')
          .tooltip('show');
      }
    })
    .on('dragover', function(evt) {
      evt.preventDefault();
    })
    .on('dragleave', function(evt) {
      var el = $(this);
      el.removeClass('over')
             .tooltip('hide');
    })
    .on('drop', function(evt) {
      evt.stopPropagation();
      var el = $(this),
          dest = el.parent(),
          dest_id = parseInt(dest.attr('rel')),
          source_id = parseInt(self.draggedMovie.parent().attr('rel'));
      self.get('controller').send('merge', source_id, dest_id);
    })
    .on('dragend', function(evt) {
      self.draggedMovie = null;
    });
  },

  didInsertElement: function() {
    this.setupDragDropMerge();
  }
});