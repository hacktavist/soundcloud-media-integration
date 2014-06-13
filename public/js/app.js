function playMedia(thisClip){
  var controls = thisClip.children().children()[0],
      button = thisClip.children();
  console.log(controls);
  console.log(button)
  if(controls.paused === false){
    controls.pause();
    button.removeClass("glyphicon-pause").addClass("glyphicon-play-circle");
  } else{
    controls.play();
    button.removeClass("glyphicon-play-circle").addClass("glyphicon-pause");
  }

  hasMediaStopped(controls, button);
}

function hasMediaStopped(controlsForMedia, playPauseButton){
  controlsForMedia.addEventListener("ended", function(){
    playPauseButton.removeClass("glyphicon-pause").addClass("glyphicon-play-circle");
  });
}


$(document).ready(function() {

  $('#slickcontainer').slick({
    slidesToShow: 3,
    slidesToScroll: 1,
    swipe: false,
    arrows: true
  });

});
