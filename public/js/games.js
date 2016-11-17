function navigate (url) {
  location.href = url;
}

function getBtnId (btn) {
  return $(btn).data('id');
}

$(function () {
  $('.join').click(function (e) {
    var id = getBtnId(e.target);
    navigate('/games/' + id + '/join');
  });

  $('.watch').click(function (e) {
    var id = getBtnId(e.target);
    navigate('/games/' + id);
  });
});
