//function definition

function handleFileUpload(files,folderId){
    for(var i=0; i<files.length; i++){
        var fd = new FormData();
        fd.append("files[]",files[i]);
        if(folderId){
          sendFileToServer(fd,folderId);  
        }else{
          sendFileToServer(fd);
        }
    }
}

function sendFileToServer(formData,folderId){
    
    if(folderId){
        var DataURL = "/folders/" + folderId + "/upload_file";
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
			    window.location.href = "/folders/" + folderId;
			}else{
                location.reload();
			}
        }
    });
}

function moveFile(fileId,folderId){
    
    var DataURL = location.pathname + "/files/" + fileId + "/move_file"; 
    var fd = new FormData();
    fd.append("folder",folderId);
    
    $.ajax({
        url: DataURL,
        type: "POST",
        contentType: false,
        processData: false,
        cache: false,
        data: fd,
        beforeSend:function(){
			$(".loading").removeClass("hide");
		},
        complete: function(data){
			$(".loading").addClass("hide");
			window.location.href = "/folders/" + folderId;
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

//definition end



$(function(){

    $("#droppable").on({
        "dragenter": function(){$(this).addClass("bgcolor_gray_1");},
        "dragover": function(){$(this).addClass("bgcolor_gray_1");},
        "dragleave": function(){$(this).removeClass("bgcolor_gray_1");},
        "drop": function(e){
            e.preventDefault();
            e.stopPropagation();
            $(this).removeClass("bgcolor_gray_1");
            var files = e.originalEvent.dataTransfer.files;
            handleFileUpload(files);
            $(".content").removeClass("bgcolor_gray_1").removeClass("bgcolor_gray_3");
        }
    });
    
    jQuery.event.props.push("dataTransfer");
    
    
    var dragimage_folder = new Image();
    dragimage_folder.src = "/images/folder_cursor.png";
    $(".folder").on({
        "dragenter": function(e){
            e.stopPropagation();
            $(this).addClass("bgcolor_gray_3");
        },
        "dragover": function(e){
            $(this).addClass("bgcolor_gray_3");
        },
        "dragleave": function(e){
            e.stopPropagation();
            $(this).removeClass("bgcolor_gray_3");
        },
        "drop": function(e){
            e.preventDefault();
            e.stopPropagation();
            if(e.dataTransfer.getData("file_id")){
                console.log(e.dataTransfer.getData("file_id"));
                moveFile(e.dataTransfer.getData("file_id"),$(this).data("folderId"));
            }else{
                var files = e.dataTransfer.files;
                handleFileUpload(files,$(this).data("folderId"));
            }
            $(this).removeClass("bgcolor_gray_3");
            $("#droppable").removeClass("bgcolor_gray_1");
        },
        "dragstart": function(e){
            e.dataTransfer.setDragImage(dragimage_folder,-15,-15);
            e.dataTransfer.setData("folder_id",$(this).data("folderId"));
        },
        "click": function(e){
            e.stopPropagation();
            $(".content").not(this).removeClass("bgcolor_gray_1");
            $(this).toggleClass("bgcolor_gray_1");
        },
        "dblclick": function(){
            var href = $("a",this).attr("href");
            location.href = href;
        }
    });
    
    var dragimage_file = new Image();
    dragimage_file.src = "/images/file_cursor.png";
    $(".file").on({
        "dragstart": function(e){
            e.dataTransfer.setDragImage(dragimage_file,-15,-15);
            e.dataTransfer.setData("file_id",$(this).data("fileId"));
            $(".content").not(this).removeClass("bgcolor_gray_1");
            $(this).toggleClass("bgcolor_gray_1");
        },
        "drop": function(e){
            $("#droppable").removeClass("bgcolor_gray_1");
            $(".folder").removeClass("bgcolor_gray_3");
            $(".file").removeClass("bgcolor_gray_1");
        },
        "click": function(e){
            e.stopPropagation();
            $(".content").not(this).removeClass("bgcolor_gray_1");
            $(this).toggleClass("bgcolor_gray_1");
        }
    });
    
    $(document).on({
        "dragenter dragover drop": function(e){e.preventDefault();},
        "drop": function(e){$("#droppable").removeClass("bgcolor_gray_1");},
        "click": function(e){
            $("droppable, .content").removeClass("bgcolor_gray_1");
        }
    });
   
   
   
    var current = $("#current");
    var menuUnderBar = $("#bar");
    var left = current.position.left;
    menuUnderBar.css("left",left);
    
    $(".menu_content").on({
        "mouseover": function(){
            var setLeft = $(this).position().left;
            menuUnderBar.stop().animate({
                left: setLeft
            },300,"swing");
        },
        "mouseleave": function(){
            menuUnderBar.stop().animate({
                left: left
            },300,"swing");
        }
    });
    
    
    var over_flg = false;
    $(".buttons").css("display","none");
    
    $(".menu span").click(function(){ 
        if ($(this).attr("class") == "selected"){
            $(this).removeClass("selected").next("ul").slideUp(100);
        }else{
            $(".menu span").removeClass("selected");
            $(".buttons").slideUp(100);
            $(this).addClass("selected").next("ul").slideDown(100);
        }
    });
    
    $(".content,.menu span,.buttons").hover(function(){
        over_flg = true;
    },function(){
        over_flg = false;
    });
    
    
    $(".content").on({
        "contextmenu": function(e){
            e.preventDefault();
            var clickLeft = e.pageX - 180;
            if($(".menu span",this).attr('class') != 'selected') {
                $('.menu span').removeClass('selected');
                $('.buttons').slideUp(100);
                $("ul",this).css({
                    left: clickLeft,
                    top: 0
                });
                $(".menu span",this).addClass('selected').next('ul').slideDown(100);
            }
        },
        "click": function(){
            $('.menu span').removeClass('selected');
            $('.buttons').slideUp(100);
        },    
    });
    
    $('body').click(function(){
        if (over_flg == false){
            $('.menu span').removeClass('selected');
            $('.buttons').slideUp(100);
        }
    });
    
    
    $("#addFolderButton").click(function(){
        setWindow($("#addFolderWindow"));
        setTimeout(function(){
            $("input.addFolderInput").focus();
        },400);
    });
    
    $("#addFileButton").click(function(){
        setWindow($("#addFileWindow"));
    });
    
    $(".moveFileButton").click(function(e){
        e.preventDefault();
        $("#moveFileWindow form").attr("action",location.pathname + "/files/" + $(this).data("fileId") +"/move_file");
        setWindow($("#moveFileWindow"));
    });
    
    $("#pageCover").click(function(){
        $(".window").css("display","none");
        $(this).css("display","none");
    });
    
    
    $("button.delete").on("click",function(e){
        if(!confirm("本当に削除しますか？")){
            return false;
        }else{
            location.href="/";
        }
    });
    
    
    
    //development
    $("#parentFolder span").click(function(e){
        e.stopPropagation();
        $("#parentFolder .buttons").slideToggle(100);
    });
    $("#parentFolder button").click(function(e){
        e.preventDefault();
        window.location.href = "/folders/" + $(this).data("parentId");
    });
    
    if(!($("#parentFolder").is(":visible"))){
        $("#directoryProperty").css("margin-top",75);
    }
});