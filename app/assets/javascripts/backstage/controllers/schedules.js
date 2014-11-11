Backstage.SchedulesController = Ember.ArrayController.extend(Backstage.PaginationMixin, {
  queryParams: ['page'],
  page: 1,
  itemsPerPage: 25
});