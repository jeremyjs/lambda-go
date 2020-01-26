// function navigate (url) {
//   location.href = url;
// }

// function getBtnId (btn) {
//   return $(btn).data('id');
// }

function splitUrl () {
  var href = location.href;
  console.log(href);
  var main_sections = href.split('localhost:8000/');
  console.log(main_sections);
  var sections = main_sections[1].split('/');
  console.log(sections);
  return {
    resource: sections[0],
    action: sections[1],
    id: sections[2],
  };
}

function getClickCoordinates (e) {
  var pos = $(e.target).position();
  return {
    x: e.pageX - pos.left,
    y: e.pageY - pos.top,
  };
}

function roundNearestPoint (point) {
  var round = function (n) { return Math.round(n / 18); };
  return {
    x: round(point.x) + 1,
    y: round(point.y) + 1,
  };
}

function onClickGameboard (src) {
  console.log(src);
  var gid = $('#data').data('gid');
  console.log(gid);
  return function (e) {
    var $target = $(e.target);
    console.log($target);
    var point = roundNearestPoint(getClickCoordinates(e));
    console.log(point);

    var play_url = '/games/' + gid + '/play/' + point.x + '-' + point.y;
    $.get(play_url)
    .done(function (res) {
      console.log(res);
      var d = new Date();
      var new_src = src + '?_=' + d.getMilliseconds();
      $('.game-board').attr('src', new_src);
    })
    .fail(function (err) {
      console.log(err);
    });
  };
}

$(function () {
  var id = splitUrl().id;
  $('.game-board').click(onClickGameboard($('.game-board').attr('src')));
});
