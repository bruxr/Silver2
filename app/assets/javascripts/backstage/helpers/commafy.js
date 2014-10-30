Ember.Handlebars.helper('commafy', function(value, options) {
  return new Ember.Handlebars.SafeString(value.join(', '));
});