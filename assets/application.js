jQuery(document).ready(function(){

  var progress = jQuery('#progress');
  if (! progress.length) return;

  var progressBarFill = jQuery('#progress-bar-fill');
  var progressMessage = jQuery('#progress p');
  var progressUrl = window.location.pathname + '/progress.json' + window.location.search;

  updateProgress = function(){
    jQuery.ajax(progressUrl, {
      success: function(result){
        progressBarFill.css('width', Math.round(result.percentage * 100) + '%');
        progressMessage.html(result.message);

        if (result.inProgress) {
          setTimeout(updateProgress, 1000);
        } else {
          jQuery('#return-to').show();
        }
      },
      error: function(){
        setTimeout(updateProgress, 1000);
      }
    });
  };

  jQuery(document).on('upload:started', function(){
    progress.show();
    jQuery('iframe').css({
      visibility: 'hidden',
      height: '0'
    });

    setTimeout(updateProgress, 100);
  });
});
