//function definition

function uploadFile(uploadedFiles,folderId){
    
    var formData = new FormData();
    for(var i=0; i<uploadedFiles.length; i++){
        formData.append("files[]",uploadedFiles[i]);
    }
    
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
        data: formData,
        dataType: "json",
        beforeSend:function(){
			$(".loading").removeClass("hide");
		}
	}).done(function(fileData){
        $(".loading").addClass("hide");
        if(fileData == null){
            alert("Forbidden Action:ファイルのアップロードは管理者のみ可能です。");
            return false;
        }
		if(folderId){
		    window.location.href = "/folders/" + folderId;
		}else{
		    var i,files=fileData.data;
		    for(i=0;i<files.length;i++){
		        $("#droppable").append(
		            $('<ul class="file content added" draggable="true" data-file-id="'+files[i].id+'" style="display:none">')
		            .append('<li class="icon"><img src="'+
		                    (files[i].img_existence ? '/images/file_icons/'+files[i].img_filetype+'.png' : '/images/file_icons/others.png')
		                    +'"></li>')
		            .append('<li class="name">'+files[i].name+'</li>')
		            .append('<li class="type">'+files[i].filetype+'</li>')
		            .append('<li class="size">'+files[i].size+'</li>')
		            .append('<li class="created_at">'+files[i].created_at+'</li>')
		            .append($('<li class="menu">')
		                    .append('<span></span>')
		                    .append($('<ul class="buttons">')
		                            .append('<li class="download-file"><a href="'+location.pathname+'/files/'+files[i].id+'/download">ダウンロード</a></li>')
		                            .append('<li data-file-id="'+files[i].id+'"class="move-file">移動</li>')
		                            .append('<li data-file-id="'+files[i].id+'"class="delete-file">削除</li>')
		                            .append('<li>プロパティ</li>')
		                            )
		                    )
		        );
		    }
		    $(".buttons").css("display","none");
		    $(".added").slideDown(500);
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
        data: fd,
        beforeSend:function(){
			$(".loading").removeClass("hide");
		}
    }).done(function(data){
		$(".loading").addClass("hide");
		window.location.href = "/folders/" + folderId;
    });
}


function deleteFile(fileId){
    var DataURL = location.pathname + "/files/" + fileId + "/delete"; 
    var obj = $(".file[data-file-id=" + fileId + "]");
    obj.slideUp(500,function(){
        $.ajax({
            url: DataURL,
            type: "POST",
            contentType: false,
            processData: false
        }).done(function(){
            obj.remove();
        });
    });
}

function createFolder(folderName){
    var fd = new FormData();
    fd.append("name",folderName);
    
    $.ajax({
        url: location.pathname + "/create_folder",
        type: "post",
        contentType: false,
        processData: false,
        data: fd
    }).done(function(data){
        $("#folders").append(
            $('<ul class="folder content added" draggable="true" data-folder-id="'+data.id+'" style="display:none">')
            .append('<li class="icon"><img src="/images/folder.png"></li>')
		    .append('<li class="name"><a href="/folders/'+data.id+'">'+data.name+'</a></li>')
            .append($('<li class="menu">')
                .append('<span></span>')
                .append($('<ul class="buttons">')
                    .append('<li class="download-file"><a href="'+location.pathname+'/folders/'+data.id+'/download">ダウンロード</a></li>')
                    .append('<li data-file-id="'+data.id+'"class="move-folder">移動</li>')
                    .append('<li data-file-id="'+data.id+'"class="delete-folder">削除</li>')
                    .append('<li>プロパティ</li>')
                )
            )
        );
	    $(".buttons").css("display","none");
	    $(".window").slideUp(300);
	    $("#pageCover").hide(300);
	    $(".added").delay(300).slideDown(500);
    });
}

function deleteFolder(folderId,linkSwitch){
    var DataURL = "/folders/" + folderId + "/delete";
    console.log(linkSwitch);
    if (linkSwitch){
        $.ajax({
            url: DataURL,
            type: "POST",
            dataType: "json",
            contentType: false,
            processData: false
        }).done(function(formData){
            if(formData.data.root){
                location.href = "/";
            } else {
                location.href = "/folders/" + formData.data.parentId
            }
        });
    } else {
        var obj = $(".folder[data-folder-id=" + folderId + "]");
        obj.slideUp(500,function(){
            $.ajax({
                url: DataURL,
                type: "POST",
                contentType: false,
                processData: false
            }).done(function(){
                obj.remove();
            });
        });
    }
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
var frag = document.createElement("html");

$(window).on("popstate",function(e){
    //if(e.originalEvent.state == "forward"){
      //  console.log("");
    //}else{
        $.ajax({
            data:"GET",
            url:document.referrer,
            dataType:"html"
        }).done(function(content){
            $(frag).html(content);
            $("#container").html($(frag).find("#container"));
            history.replaceState(null,null,document.referrer);
        },function(){
            $("title").remove();
            $("meta").append($(frag).find("title"));
            $(".buttons").css("display","none");
        });
    //}
});

/*
if(window.history.state == "forward"){
    console.log("oh yeah");
}
*/


$(function(e){
    
    if(!e.originalEvent){
        history.pushState("forward",null,document.pathname);
    }
    
    
    $(document).on({
        "dragenter": function(){$(this).addClass("bgcolor_gray_1");},
        "dragover": function(){$(this).addClass("bgcolor_gray_1");},
        "dragleave": function(){$(this).removeClass("bgcolor_gray_1");},
        "drop": function(e){
            e.preventDefault();
            e.stopPropagation();
            $(this).removeClass("bgcolor_gray_1");
            var files = e.originalEvent.dataTransfer.files;
            uploadFile(files,null);
            $(".content").removeClass("bgcolor_gray_1").removeClass("bgcolor_gray_3");
        }
    },"#droppable");
    
    jQuery.event.props.push("dataTransfer");
    
    
    var dragimage_folder = new Image();
    dragimage_folder.src = "/images/folder_cursor.png";
    $(document).on({
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
                moveFile(e.dataTransfer.getData("file_id"),$(this).data("folderId"));
            }else{
                var files = e.dataTransfer.files;
                uploadFile(files,$(this).data("folderId"));
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
    },".folder");
    
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
    
    $(document).on("click",".menu span",function(){ 
        if ($(this).attr("class") == "selected"){
            $(this).removeClass("selected").next("ul").slideUp(100);
        }else{
            $(".menu span").removeClass("selected");
            $(".buttons").slideUp(100);
            $(this).addClass("selected").next("ul").slideDown(100);
        }
    });
    
    $(document).on({
        "mouseenter":function(){
            over_flg = true;
        },
        "mouseleave":function(){
            over_flg = false;
        }
    },".content,.menu span,.buttons");
    
    
    $(document).on({
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
    },".content");
    
    $(document).not(".content,.menu span,.buttons").on("click",function(){
        if (over_flg == false){
            $('.menu span').removeClass('selected');
            $('.buttons').slideUp(100);
        }
    });
    
    
    $(document).on("click","#new_folder_button",function(){
        setWindow($("#new_folder"));
        setTimeout(function(){
            $("input.new-folder-input").focus();
        },400);
    });
    
    $(document).on("click","#addFileButton",function(){
        setWindow($("#addFileWindow"));
    });
    
    $(document).on("click",".moveFileButton",function(e){
        e.preventDefault();
        $("#moveFileWindow form").attr("action",location.pathname + "/files/" + $(this).data("fileId") +"/move_file");
        setWindow($("#moveFileWindow"));
    });
    
    $(document).on("click",".delete-file",function(){
        deleteFile($(this).data("fileId"));
    });
    
    $(document).on("click","#new_folder button",function(e){
        e.preventDefault();
        createFolder($("input.new-folder-input").val());
    });
    
    $(document).on("click",".delete-folder",function(){
        if($(this).attr("id") == "link_switch"){
            var linkSwitch = true;
        }else{
            var linkSwitch = false;
        }
        deleteFolder($(this).data("folderId"),linkSwitch);
    });
    
    $(document).on("click","#pageCover",function(){
        $(".window").css("display","none");
        $(this).css("display","none");
    });
    
    
    $(document).on("click","button.delete",function(e){
        if(!confirm("本当に削除しますか？")){
            return false;
        }else{
            location.href="/";
        }
    });
    
    
    
    //development
    $(document).on("click","#parentFolder span",function(e){
        e.stopPropagation();
        $("#parentFolder .buttons").slideToggle(100);
    });
    $(document).on("click","#parentFolder button",function(e){
        e.preventDefault();
        window.location.href = "/folders/" + $(this).data("parentId");
    });
    
    if(!($("#parentFolder").is(":visible"))){
        $("#directoryProperty").css("margin-top",75);
    }
});