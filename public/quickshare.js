function sendFileToServer(formData){
    var DataURL = location.pathname + "/upload_file";
    $.ajax({
        url: DataURL,
        type: "POST",
        contentType: false,
        processData: false,
        cache: false,
        data: formData,
        beforeSend:function(){
			$(".loading").removeClass("hide");
		},
        complete: function (data) {
			$(".loading").addClass("hide");
            location.reload();
        }
    });
}
   
function handleFileUpload(files,obj){
   for(var i = 0; i < files.length; i++){
       var fd = new FormData();
       fd.append("file",files[i]);
       
       console.log(files[i].name);
       sendFileToServer(fd);
       
   }
}

$(function(){
   var obj=$("#droppable");
   obj.on("dragenter",function(e){
       e.stopPropagation();
       e.preventDefault();
       $(this).css("background-color","rgba(0,0,0,0.1)");
   }).on("dragover",function(e) {
       e.stopPropagation();
       e.preventDefault();
       $(this).css("background-color","rgba(0,0,0,0.1)");
   }).on("drop",function(e){
      $(this).css("background-color","mintcream");
      e.preventDefault();
      var files = e.originalEvent.dataTransfer.files;
      handleFileUpload(files,obj);
   }).on("dragleave",function(e){
       e.stopPropagation();
       e.preventDefault();
       $(this).css("background-color","mintcream");
   });
   
   $(document).on("dragenter",function(e) {
       e.stopPropagation();
       e.preventDefault();
   }).on("dragover",function(e) {
       e.stopPropagation();
       e.preventDefault();
   }).on("drop",function(e) {
       e.stopPropagation();
       e.preventDefault();
       $("#dropzone").css("background-color","#fff");
   });
   
   var current = $("#current");
   var menuUnderBar = $("#bar");
   var left = current.position().left;
   console.log(left);
   menuUnderBar.css("left",left);
   
   $(".menu_content").on("mouseover",function(){
       var setLeft = $(this).position().left;
       menuUnderBar.stop().animate({
           left: setLeft
       },300,"swing");
   }).on("mouseleave",function(){
       menuUnderBar.stop().animate({
           left: left
       },300,"swing");
   });
   
   var over_flg = false;
   $(".buttons").css("display","none");
   $(".menu").on("mouseover",function(){
       $(this).css("background-color","rgba(0,0,0,0.2)");
   }).on("mouseleave",function(){
       $(this).css("background-color","mintcream");
   });
   
   $(".content").not(".menu").on("mouseover",function(){
       if (over_flg == false){
        $(".menu").css("background-color","rgba(0,0,0,0)");
       }
   }).on("mouseleave",function(){
        $(".menu").css("background-color","mintcream");
   });
   
   $(".menu span").click(function() { 
    if ($(this).attr('class') == 'selected') {
      $(this).removeClass('selected').next('ul').slideUp(100);
    } else {
      $('.menu span').removeClass('selected');
      $('.buttons').slideUp(100);
      $(this).addClass('selected').next('ul').slideDown(100);
    }    
  });
    $('.menu span,.buttons').hover(function(){
    over_flg = true;
  }, function(){
    over_flg = false;
  });  
    $('body').click(function() {
    if (over_flg == false) {
      $('.menu span').removeClass('selected');
      $('.buttons').slideUp(100);
    }
  });
  
  $("#addFolderButton").on("click",function(){
    $("#pageCover").css("display","block");
    var windowWidth = $("#addFolderWindow").width();
    var pageWidth = $(document).width();
    var setLeft = (pageWidth - windowWidth) / 2;

    $("#addFolderWindow").css({
        left: setLeft,
        top: "150px"
    });
    $("#addFolderWindow").slideDown(300);
  });
  
  $("#pageCover").on("click",function(){
    $("#addFolderWindow").css("display","none");
    $(this).css("display","none");  
  });

});