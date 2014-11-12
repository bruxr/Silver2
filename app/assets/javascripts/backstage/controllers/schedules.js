Backstage.SchedulesController = Ember.ArrayController.extend(Backstage.PaginationMixin, {
  queryParams: ['page', 'date', 'cinema', 'movie'],
  page: 1,
  date: '2014-11-11',
  cinema: -1,
  movie: -1,
  itemsPerPage: 25,
  
  actions: {
    
    deleteSchedule: function(sked) {
      if (confirm('Are you sure you want to delete this schedule?')) {
        sked.destroyRecord();
      }
    }
    
  }
});