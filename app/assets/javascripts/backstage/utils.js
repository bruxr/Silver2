Backstage.Utils = {
  
  // Converts underscored keys in a hash
  // to their camelCase version.
  unserialize: function(h) {
    var r = {};
    $.each(h, function(k, v) {
      k = Ember.String.camelize(k);
      r[k] = v
    });
    return r;
  }
  
};