Ember.Handlebars.helper('calendarTime', function(value, options) {
  return moment(value).calendar();
});