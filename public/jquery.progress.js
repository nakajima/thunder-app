(function($) {
  var elems = [];

  function pinger(i, elem) {
    var elem = $(this);
    var opts = elem.data('progress-options');

    opts.dot = opts.dot || '.';
    opts.size |= 3;
    opts.start = opts.start || opts.dot;

    var size = $.trim(elem.text() || '').length;

    if (size == opts.size) {
      elem.text(opts.start);
    } else {
      var dots = opts.start
      while(size--) { dots = dots + opts.dot; }
      elem.text(dots);
    }
  }

  function run() {
    for (i in elems) { elems[i].each(pinger) }
    window.setTimeout(run, 400);
  }

  $.fn.progress = function progress(options) {
    var elem = $(this);
    elems.push(elem);
    elem.css({ position: 'absolute' });
    elem.data('progress-options', (options || {}));
    return elem;
  }

  run();
})(jQuery);
