// Pagination mixin based on:
// http://stackoverflow.com/questions/13008838/ember-pagination-full-example
Backstage.PaginationMixin = Ember.Mixin.create({
  
  itemsPerPage: 10,
  
  // Returns an array of objects containing
  // the available pages.
  // Example:
  // [{ page_id: 1 }, { page_id: 2 }]
  pages: function() {
    var availablePages = this.get('availablePages'),
        pages = [];
    for (i = 0; i < availablePages; i++) {
      pages.push(i + 1);
    }
    return pages;
  }.property('availablePages'),
  
  currentPage: function() {
    return parseInt(this.get('selectedPage'), 10) || 1;
  },
  
  nextPage: function() {
    var nextPage = this.get('currentPage') + 1,
        availablePages = this.get('availablePages');
    if (nextPage <= availablePages) {
      return nextPage;
    }
    else {
      return this.get('currentPage');
    }
  }.property('currentPage', 'availablePages'),
  
  prevPage: function() {
    var prevPage = this.get('currentPage') - 1;
    if (prevPage > 0) {
      return prevPage;
    }
    else {
      return this.get('currentPage');
    }
  }.property('currentPage'),
  
  availablePages: function() {
    return Math.ceil((this.get('content.length') / this.get('itemsPerPage')) || 1)
  }.property('content.length'),
  
  paginatedContent: function() {
    var selectedPage = this.get('page') || 1,
        upperBound = (selectedPage * this.get('itemsPerPage')),
        lowerBound = (selectedPage * this.get('itemsPerPage') - this.get('itemsPerPage')),
        models = this.get('content');
    return models.slice(lowerBound, upperBound);
  }.property('page', 'content.@each')
  
});