function init_vimeo_iframe (mode, height) {
  rbf_selectQuery('SELECT sc_id, sc_cs, sc_at FROM $SETTINGS', 1, function (vals) {
    var iframeWidth = '900px',
        cid = vals[0][0],
        cs = vals[0][1],
        at = vals[0][2],
        applicationId = getURLParameter('id'),
        visitorId = current_visitor.id,
        iframe = $("<iframe height='" + height + "'></iframe>"),
        container = $("<div class='flex-video widescreen'></div>"),
        // url = ["https://sinatra-blahaas.rhcloud.com",
        url = ["https://soundcloud-gdgqaas.rhcloud.com",
              cid,
              cs,
              at]
              // visitorId,
              // applicationId,
              // mode];

    url = url.join('/');
    container.appendTo('[name="SoundCloud Content Target"]');
    iframe.prop('src', url).appendTo('.flex-video');
  });
}

$('document').ready(function () {
  var g = getURLParameter('g');
  if (g == portal_pages.sound_edit_page) {
    init_vimeo_iframe('e', '2000px');
  }
  else if (g == portal_pages.video_review_page) {
    init_vimeo_iframe('v', '500px');
  }
  else if (g == portal_pages.video_view_page) {
    init_vimeo_iframe('v', '500px');
  }
});
