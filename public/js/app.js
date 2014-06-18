function playMedia(thisClip){
  var controls = thisClip.children()[1],
      button = thisClip.children()[0];
  console.log(controls);
  console.log(button)
  if(controls.paused === false){
    controls.pause();
    //button.removeClass("fa-pause overAvatarHover").addClass("fa-play-circle-o");
    button.className="";
    button.className="fa fa-5x fa-play-circle-o overAvatar";
  } else{
    controls.play();
    //button.removeClass("fa-play-circle-o").addClass("fa-pause overAvatarHover");
    button.className="";
    button.className="fa fa-5x fa-pause overAvatar overAvatarHover";
  }

  hasMediaStopped(controls, button);
}

function hasMediaStopped(controlsForMedia, playPauseButton){
  controlsForMedia.addEventListener("ended", function(){
    //playPauseButton.removeClass("fa-pause overAvatarHover").addClass("fa-play-circle-o");
    playPauseButton.className="";
    playPauseButton.className="fa fa-5x fa-play-circle-o overAvatar";
  });
}

function hoveringOnPlay(){
  $('.overAvatar').mouseOver(function(){
    //
  })
}

function soundUploadSpinner(){
 //upload form stuff

  $('#upload-form').on('submit', function(e) {


      //console.log("UploadSpinner");
      $('#backButton').hide();
      e.preventDefault();
      $('[type=submit]').prop('disabled',true).val('Uploading, Please Wait...' /*<i class="fa fa-spin fa-spinner">'*/);
      // $('#uploadModal').modal('hide');
      $(this).off('submit').submit();
  });
}

function deleteModal(soundID){
  var confirmation = confirm("Are you sure you want to delete this sound?");

  if (confirmation) {
    //$('#' + id).find('.fa-check-circle-o').removeClass('fa-check-circle-o').addClass('fa-spinner fa-spin')
    $.get('/tracks/delete/' + soundID, function(data) {
      //$('#' + id).remove();
      alert("This video has been successfully deleted");
    }).fail(function(){
      alert("Oops! Something went wrong, please try again");
      $('#' + id).find('.fa-spinner').removeClass('fa-spinner fa-spin').addClass('fa-check-circle-o')
    });
  }
}

function buildHTMLError(){
  // Build string and prepend it to the body tag.
  var htmlString = '<p id="myError" style>Error: ​File size must be greater than 15 KB.​</p>';
  $("body").prepend(htmlString);
  $("#myError").addClass("​alert alert-danger");
  //hide flash message after 5 seconds
  setTimeout(function () {
    $('#myError').hide();
  }, 5000);
}

function validateUploadForm(){
  var title = $('#title'),
      description = $('#descr'),
      sound = $('#file'),
      bool = false;
  if(title == '' || description == '' || sound == ''){
    bool = false;
  } else {
    bool = true;
  }

  return bool;

}

$(document).ready(function() {
  var uploadFormExists = $('#upload-form').length,
      slickContainerExists = $('#slickcontainer').length;

  if(uploadFormExists > 0){
    soundUploadSpinner();
  }

  if(slickContainerExists > 0){
    $('#slickcontainer').slick({
      dots: true,
      infinite: true,
      speed: 300,
      slidesToShow: 3,
      slidesToScroll: 1,
      arrows: true
    });
  }
});
