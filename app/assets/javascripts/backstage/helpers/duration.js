Ember.Handlebars.helper('duration', function(value, options) {
  value = parseInt(value);
  if (value <= 0 || isNaN(value)) {
    return new Ember.Handlebars.SafeString('? mins');
  }
  else {
    var hours = Math.floor(value / 60),
        mins = value % 60,
        str = '';
    if (hours > 0) { str += "%d hrs".replace('%d', hours); }
    str += " %d mins".replace('%d', mins);
    return new Ember.Handlebars.SafeString(str);
  }
});