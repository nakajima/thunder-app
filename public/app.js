(function($) {
  function toggle(event) {
    if ($(event.target).is('.link')) { return; }
    $(this).toggleClass('faded');
    return halt(event);
  }

  function halt() {
    return $(event.target).is('.link') ? confirm('Sure?') : false;
  }

  function showAll() {
    $('.repo').removeClass('faded');
    return false;
  }

  function hideAll() {
    $('.repo').addClass('faded');
    return false;
  }

  $(document).ready(function() {
    $('.repo').live('mousedown', toggle);
    $('.repo').live('click', halt);
    $('a[href="#show"]').live('click', showAll);
    $('a[href="#hide"]').live('click', hideAll);
  });
})(jQuery);
