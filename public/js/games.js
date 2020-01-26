function navigate (url) {
  location.href = url;
}

$(function () {
  $('.join').click(function (e) {
    var id = $(e.target).data('id');
    var uid = $('#data').data('uid');
    navigate('/games/' + id + '/join/' + uid);
  });

  $('.watch').click(function (e) {
    var id = $(e.target).data('id');
    navigate('/games/' + id + '/watch');
  });
});
