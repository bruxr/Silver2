Ember.Handlebars.helper('scorebar', function(value, options) {
  
  var color,
      GRAPH_HEIGHT = 200,
      height = GRAPH_HEIGHT * (value * 0.1); // value is 0-10
  
  if (value <= 3) { color = 'red' }
  else if (value <= 7) { color = 'yellow' }
  else { color = 'green' }
  
  value = parseFloat(value).toFixed(1);
  
  return new Ember.Handlebars.SafeString('<div class="bar %s" style="height: %fpx">%d</div>'.replace('%s', color).replace('%f', height).replace('%d', value));

});