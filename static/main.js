$(function(){
  $.getJSON("fetchRSS", function(data){
    console.log(data.concat());
    var stories = []
    for(var feed in data){
      story = data[feed]
      stories = $.merge(story, stories)
    }
    console.log(stories)
    $("#stories").html(stories)

  });
});
