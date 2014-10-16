Silver.MovieGridView = Ember.View.create({
  templateName: 'movie-grid',
  didInsertElement: function() {
    $('img.fi', this.$()).each(function(i, el) {
      $(el).on('load', function() { this.className = this.className + ' fi-loaded'; })
    });
  }
});