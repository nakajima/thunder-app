(function($) {
  var PROGRESS_ELEMS = [];

  function pinger(i, elem) {
    elem = $(elem);
    var opts = elem.data('progress-options');
    opts.dot = '.';
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
    for (i in PROGRESS_ELEMS) { PROGRESS_ELEMS[i].each(pinger) }
    window.setTimeout(run, 400);
  }

  $.fn.progress = function progress(options) {
    $(this).css({ position: 'absolute' }).data('progress-options', (options || {}))
    PROGRESS_ELEMS.push(this);
    return this;
  }

  run();
})(jQuery);
