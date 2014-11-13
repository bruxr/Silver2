(function($) {

  function Mirror(el, opts) {
    
    var IMAGE_TYPES = ['image/jpeg', 'image/gif', 'image/png'],
        file = null;
    
    function isImage(mime) {
      return $.inArray(mime, IMAGE_TYPES) >= 0;
    }
    
    function followMouse(evt) {
      var el = $(this),
          input = $('input.mirror-input', el);
      input.css({
        top: evt.clientY - 20,
        left: evt.clientX - 20
      })
    }
    
    function fileChanged(evt) {
      
      if (evt.target.files.length == 0) return;
      
      file = evt.target.files[0];
      
      if (!isImage(file.type)) {
        alert('Please upload a valid image.');
        return;
      }
      
      var reader = new FileReader();
      reader.onload = function(e) {
        $(opts.mirrorTo).attr('src', e.target.result);
      };
      reader.readAsDataURL(file);
      
    }
    
    function uploadFile() {
      var data = new FormData();
      data.append('file', file, file.name);
      return $.ajax({
        url: opts.url,
        type: 'POST',
        data: data,
        cache: false
      });
    }
    
    el.on('mouseover', function() {
      var input = $('<input type="file" style="cursor: pointer; opacity: 0.2; position: fixed" class="mirror-input">');
      input.on('change', fileChanged);
      el.append(input)
        .on('mousemove', followMouse);
    }).on('mouseout', function() {
      el.off('mousemove', followMouse);
      $('.input.mirror-input', el).remove();
    });
    
    return {
      upload: uploadFile
    }
    
  };
  
  $.fn.mirror = function(opts) {
    if (typeof opts == 'undefined') opts = {}; 
    if (typeof opts == 'string') {
      switch(opts) {
        case 'upload':
          return $(this).eq(0).data('mirror').upload();
        break;
      }
    }
    else {
      var defaults = {
        mirrorTo: null,
        url: ''
      }
      opts = $.extend({}, defaults, opts);
      return this.each(function() {
        var el = $(this)
        el.data('mirror', new Mirror(el, opts));
      });
    }
  };
  
})(jQuery);