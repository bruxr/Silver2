Ember.Handlebars.helper('tieredPrice', function(value, options) {
  var prices = '';
  if (typeof value.default !== 'undefined') {
    if (value.default !== null) prices = value.default;
  }
  else if (typeof value === 'object') {
    prices = [];
    Object.keys(value).forEach(function(key) {
      prices.push(value[key])
    });
    prices = prices.join('/');
  }
  else {
    prices = value;
  }
  return new Ember.Handlebars.SafeString(prices);
});