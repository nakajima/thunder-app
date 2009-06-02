(function($) {
  function finish() {
    var winner = $('.repo:not(.faded):visible')
    winner.addClass('winner');
    $('#winner').show().text(winner.find('h3').text() + ' is what you should talk about!');
    $('#loser').hide();
  }

  function fail() {
    $('#loser').show();
  }

  function toggle(event) {
    if ($(event.target).is('.link')) { return; }
    $(this).toggleClass('faded');
    showMessages();
    return halt(event);
  }

  function showMessages() {
    var remaining = $('.repo:not(.faded):visible').size()
    if (remaining == 1) { return finish(); }
    $('.winner').removeClass('winner');
    $('#winner').hide().text('');
    if (remaining == 0) { return fail(); }
    $('#loser').hide();
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
    showMessages();
    return false;
  }

  function hideAll() {
    $('.repo').addClass('faded');
    showMessages();
    return false;
  }

  $(document).ready(function() {
    $('.repo').live('mousedown', toggle);
    $('.repo').live('click', halt);

    $('a[href="#show"]').live('click', showAll);
    $('a[href="#hide"]').live('click', hideAll);
    $('.progress').progress();

    $('input[name="q"]').search('.repo', function(on) {
      on.reset(function() {
        $('.repo').show();
      });

      on.results(function(results) {
        $('.repo').hide();
        results.show();
      });
    });

    if (input = $('input[name="username"]').get(0)) {
      input.focus();
      input.select();
    }
  });
})(jQuery);
