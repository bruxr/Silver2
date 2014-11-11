Backstage.SchedulesView = Ember.View.extend({
  name: 'schedules',
  templateName: 'schedules',
  didInsertElement: function() {
    var d = new Date();
    $('.schedules-filter input[type=date]').val(d.toISOString().slice(0, 10));
  }
});