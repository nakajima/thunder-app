(function($) {
  function finish() {
    var winner = $('.repo:not(.faded)')
    winner.addClass('winner');
    $('#winner').show().text(winner.find('h3').text() + ' is the winner!');
  }
  
  function toggle(event) {
    if ($(event.target).is('.link')) { return; }
    $(this).toggleClass('faded');
    if ($('.repo:not(.faded)').size() == 1) {
      finish();
    } else {
      $('.winner').removeClass('winner');
      $('#winner').hide().text('');
    }
    return halt(event);
  }

  function halt() {
    var elem = $(event.target);
    if (elem.is('.link')) {
      var href = elem.attr('href');
      return confirm('Go to ' + href + '?');
    } else {
      return false;
    }
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
