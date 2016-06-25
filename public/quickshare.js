function sendFileToServer(formData,folderId){
    if(folderId){
     var DataURL = location.pathname + "/" + folderId + "/upload_file";
    }else{
      var DataURL = location.pathname + "/upload_file";  
    }
    
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
			if(folderId){
			    window.location.href = location.pathname + "/" + folderId;
			}else{
                location.reload();
			}
        }
    });
}

function handleFileUpload(files,obj){
    for(var i=0; i < files.length; i++){
        var fd = new FormData();
        fd.append("files[]",files[i]);
        if(obj){
          id = obj.data("folderId");
          sendFileToServer(fd,id);  
        }else{
          sendFileToServer(fd);
        }
    }
}

function moveFile(fileId,folderId){
    
    var DataURL = location.pathname + "/files/" + fileId + "/move_file";  
    
    $.ajax({
        url: DataURL,
        type: "POST",
        contentType: false,
        processData: false,
        cache: false,
        data: folderId,
        beforeSend:function(){
			$(".loading").removeClass("hide");
		},
        complete: function (data) {
			$(".loading").addClass("hide");
			window.location.href = location.pathname + "/" + folderId;
        }
    });
}

function setWindow(obj){
    $("#pageCover").css("display","block");
    var windowWidth = obj.width();
    var pageWidth = $(document).width();
    var setLeft = (pageWidth - windowWidth) / 2;

    obj.css({
        left: setLeft,
        top: "150px"
    });
    
    obj.slideDown(300);
}

$(function(){
    
    jQuery.event.props.push("dataTransfer");
    
    
   var obj=$("#droppable");
   obj.on("dragenter",function(e){
        $(this).css("background-color","rgba(0,0,0,0.1)");
   }).on("dragover",function(e) {
       $(this).css("background-color","rgba(0,0,0,0.1)");
   }).on("drop",function(e){
       e.stopPropagation();
       e.preventDefault();
      $(this).css("background-color","mintcream");
      var files = e.originalEvent.dataTransfer.files;
      handleFileUpload(files);
   }).on("dragleave",function(e){
       $(this).css("background-color","mintcream");
   });
   
    $(".folder").on("dragenter",function(e){
        e.stopPropagation();
        $(this).addClass("folder_hover");
    }).on("dragover",function(e){
        e.preventDefault();
        e.stopPropagation();
        $(this).addClass("folder_hover");
    }).on("dragleave",function(e){
        e.stopPropagation();
        $("#droppable").css("background-color","mintcream");
        $(this).removeClass("folder_hover");
    }).on("drop",function(e){
        e.preventDefault();
        e.stopPropagation();
        var files = e.dataTransfer.files;
        handleFileUpload(files,$(this));
    });
   
   $(".file").bind("dragstart",function(e){
       e.dataTransfer.setData("file_id",$(this).data("fileId"));
       console.log(e.dataTransfer.getData("fileId"));
   });
   
   $(document).on("dragenter",function(e) {
       e.preventDefault();
   }).on("dragover",function(e) {
       e.preventDefault();
   }).on("drop",function(e){
       e.preventDefault();
       $("#droppable").css("background-color","mintcream");
   });
   
   
   
   
   var current = $("#current");
   var menuUnderBar = $("#bar");
   var left = current.position().left;
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
   
   $(".menu span").click(function() { 
    if ($(this).attr('class') == 'selected') {
      $(this).removeClass('selected').next('ul').slideUp(100);
    } else {
      $('.menu span').removeClass('selected');
      $('.buttons').slideUp(100);
      $(this).addClass('selected').next('ul').slideDown(100);
    }    
  });
    $('.content,.menu span,.buttons').hover(function(){
    over_flg = true;
  }, function(){
    over_flg = false;
  });
  
  var menu_open = false;
  $(".content").on("contextmenu",function(e){
    e.preventDefault();
    menu_open = true;
    var clickLeft = e.pageX - 70;
    if ($(".menu span",this).attr('class') != 'selected') {
        console.log("open");
      $('.menu span').removeClass('selected');
      $('.buttons').slideUp(100);
      $("ul",this).css({
        left: clickLeft,
        top: 0
      });
      $(".menu span",this).addClass('selected').next('ul').slideDown(100);
    }
  }).on("click",function(){
    $('.menu span').removeClass('selected');
     $('.buttons').slideUp(100);
     menu_open = false;
  });
  
    $('body').click(function() {
    if (over_flg == false) {
      $('.menu span').removeClass('selected');
      $('.buttons').slideUp(100);
      menu_open = false;
    }
  });
  
  $("#addFolderButton").on("click",function(){
    setWindow($("#addFolderWindow"));
    setTimeout(function(){
        $("input.addFolderInput").focus();
    },400);
  });
  
  $("#addFileButton").on("click",function(){
    setWindow($("#addFileWindow"));
  });
  
  $(".moveFileButton").on("click",function(e){
      e.preventDefault();
      $("#moveFileWindow form").attr("action",location.pathname + "/files/" + $(this).data("fileId") +"/move_file");
      setWindow($("#moveFileWindow"));
  });
  
  $("#pageCover").on("click",function(){
    $(".window").css("display","none");
    $(this).css("display","none");
  });
  
  
  
  
  
  
  $(".folder").on("dblclick",function(){
    var href = $("a",this).attr("href");
    location.href = href;
  });
  
  $("button.delete").on("click",function(e){
    if(!confirm("本当に削除しますか？")){
        return false;
    }else{
        location.href="/";
    }
  });

});