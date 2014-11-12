Backstage.SchedulesController = Ember.ArrayController.extend(Backstage.PaginationMixin, {
  queryParams: ['page', 'date', 'cinema', 'movie'],
  page: 1,
  date: '2014-11-11',
  cinema: -1,
  movie: -1,
  itemsPerPage: 25
});