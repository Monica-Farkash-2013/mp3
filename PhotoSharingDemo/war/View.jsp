<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.google.cloud.demo.*"%>
<%@ page import="com.google.cloud.demo.model.*"%>
<%@ page import="com.google.appengine.api.users.*"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreNeedIndexException"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  UserService userService = UserServiceFactory.getUserService();
  AppContext appContext = AppContext.getAppContext();
  ConfigManager configManager = appContext.getConfigManager();
  DemoUser currentUser = appContext.getCurrentUser();
  PhotoServiceManager serviceManager = appContext.getPhotoServiceManager();
  PhotoManager photoManager = appContext.getPhotoManager();
  CommentManager commentManager = appContext.getCommentManager();
  AlbumManager albumManager = appContext.getAlbumManager();
  ViewManager viewManager = appContext.getViewManager();
  LeaderboardManager leaderboardManager = appContext.getLeaderboardManager();
  SubscriptionManager subscriptionManager = appContext.getSubscriptionManager();
%>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Connexus Photo Album Mananger</title>
<!-- Bootstrap core CSS -->
<link href="../../bootstrap/css/bootstrap.css" rel="stylesheet">

 <!-- Force latest IE rendering engine or ChromeFrame if installed -->
 <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"><![endif]-->
 <meta charset="utf-8">
 <!-- Bootstrap CSS Toolkit styles -->
 <link rel="stylesheet" href="css/bootstrap.min.css">
 <!-- Generic page styles -->
 <link rel="stylesheet" href="css/style.css">
 <!-- Bootstrap styles for responsive website layout, supporting different screen sizes -->
 <link rel="stylesheet" href="css/bootstrap-responsive.min.css">
 <!-- Bootstrap CSS fixes for IE6 -->
 <!--[if lt IE 7]><link rel="stylesheet" href="http://blueimp.github.com/cdn/css/bootstrap-ie6.min.css"><![endif]-->
 <!-- Bootstrap Image Gallery styles -->
 <link rel="stylesheet" href="css/bootstrap-image-gallery.min.css">
 <!-- CSS to style the file input field as button and adjust the Bootstrap progress bars -->
 <link rel="stylesheet" href="css/jquery.fileupload-ui.css">
 <!-- Shim to make HTML5 elements usable in older Internet Explorer versions -->
 <!--[if lt IE 9]><script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script><![endif]-->

 <!-- Bootstrap core JavaScript
 ================================================== -->
 <!-- Placed at the end of the document so the pages load faster -->
 <script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
 <script src="../../bootstrap/js/bootstrap.min.js"></script>

<!-- Custom styles for this template -->
<link href="navbar.css" rel="stylesheet">

<script type="text/javascript">
function isAlbumCover(sel, isCover) {
	var element;
	if( sel == 1)
		element = document.getElementById("selectCover1");
	else if( sel == 2)
		element = document.getElementById("selectCover2");
	else if( sel == 3)
		element = document.getElementById("selectCover3");
	var show = element.style.visibility;
	if (isCover)
		element.style.visibility = "visible";			
	else
		element.style.visibility = "hidden";
}


function selectCover(sel, url) {
	//alert("We got a pageShow call!..."); 
	var element;
	if( sel == 1)
		element = document.getElementById("selectCover1");
	else if( sel == 2)
		element = document.getElementById("selectCover2");
	else if( sel == 3)
		element = document.getElementById("selectCover3");
	var show = element.style.visibility;
	if (show == "visible")
		element.style.visibility = "hidden";			
	else
		element.style.visibility = "visible";
	var allUrl = "http://"; 
	allUrl = allUrl.concat(document.location.host);
	document.location.replace(allUrl.concat(url));
}


</script>

</head>
<body>
    <div class="container">

      <!-- Static navbar -->
      <div class="navbar navbar-default" role="navigation">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#"><img src="img/photofeed.png" alt="Connexus" /></a>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
            <li><a href="Manage.jsp">Manage</a></li>
            <li><a href="Create.jsp">Create</a></li>
            <li class="active"><a href="Connexus.jsp">View</a></li>
            <li><a href="Search.jsp">Search</a></li>
            <li><a href="Trending.jsp">Trending</a></li>
            <li><a href="Social.jsp">Social</a></li>
          </ul>
          <ul class="nav navbar-nav navbar-right">
    		<%if(currentUser != null) { %>  
            <li><a>Hello <%= ServletUtils.getProtectedUserNickname(currentUser.getNickname()) %> , 
                  <%= currentUser.getEmail() %></a></li>
            <li class="active">
                  <a href=<%= userService.createLogoutURL(configManager.getLoginPageUrl())%>>Sign out</a>
   			<% } else {%>
            <li class="active">
                  <a href=<%= userService.createLoginURL(configManager.getMainPageUrl())%>>Sign in</a>   
   			<% } %>  
    		</li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>

	<%
	String streamId = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID); 
	String which_photos = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_PHOTO_LOC);
	int start_with_photo =1;
	if (which_photos != null) start_with_photo = Integer.valueOf(which_photos); 
	if(streamId != null && !streamId.isEmpty())
	{
		String streamUserId = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID);
		viewManager.addAlbumView(streamId);
	%>
		<div class="view-title">
		<%
		Album albm = albumManager.getAlbum(streamUserId, Long.parseLong(streamId));
		if (albm != null) {	
		%>
			<p>View pictures from stream: "<%= albm.getTitle()%>"
	  		posted by user: "<%= albm.getOwnerNickname() %>" </p>
	  		<div class="fb-like" data-href="http://developers.facebook.com/docs/reference/plugins/like" data-width="450" data-show-faces="true" data-send="true">
		    </div>  
	  		
		<%
		}
		%>
		<% 
	    if	(currentUser != null) { 
		  if(currentUser.getUserId().toString().compareTo(streamUserId) != 0)
		  {
		%>
						<%-- MM: Subscribe  --%>
	        <div class="subscribe">
	        <% 
	        String subscribe = "Subscribe";
	        subscribe = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_SUBSCRIBE);
	        if(subscribe == null)	
	        	subscribe = "Subscribe";
	        else {
	        	if (subscribe.compareTo("Subscribe") == 0) {
	        		subscribe = "Unsubscribe";
	        		if(!subscriptionManager.isSubscribed(albm.getId().toString(), currentUser.getUserId().toString()))
	        			subscriptionManager.addSubscription(albm.getId().toString(), currentUser.getUserId().toString());
	        	}
	        	else {
	        		if (subscribe.compareTo("Unsubscribe") == 0) {
	        			subscribe = "Subscribe";
	        			if(subscriptionManager.isSubscribed(albm.getId().toString(), currentUser.getUserId().toString()))
	       					subscriptionManager.unSubscribe(albm.getId().toString(), currentUser.getUserId().toString());        	
	        		} 
	        		else 
	        			subscribe = "Subscribe";
	        	}
	        }
	        %>
	        	<form action="<%= serviceManager.getSubscribeUrl(null, streamUserId, null, 
	                     				albm.getId().toString(), 
	                     				ServletUtils.REQUEST_PARAM_NAME_VIEW_STREAM, subscribe) %>"
	                 method="post">    
	                   <input id="btn-post" class="active btn" type="submit" value=<%= subscribe %>>
	            </form>
	        </div>
		<% 
		} } else {
		%>	
	     <p>Please login in order to subscribe to this stream...</p>	    			
		<% } %>
		</div>
		
    <%-- MM: adds the new picture to the album  --%>
    	<!-- KK -->
    	<%
      	Iterable<Photo> photoIter = photoManager.getSubsetOwnedAlbumPhotos(streamUserId, streamId, 3, start_with_photo-1);
      	ArrayList<Photo> photos = new ArrayList<Photo>();
      	int count=0;
      	try {
        	for (Photo photo : photoIter) {
          			photos.add(photo); 
          			
          			count++; 
          			if(count >= 3)
          				break;
        	}
      	} catch (DatastoreNeedIndexException e) {
        	pageContext.forward(configManager.getErrorPageUrl(
          		ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
      	}

      
      	%>
      	<div class="bubble">
      	 <img onmouseover="this.src='img/choose.png'" onmouseout="this.src=''" src="img/choose.png"/>
      	 </div>
      	<%
      	
        /* goes over the pictures, one by one, to be shown to the public */
      	  count = 0;
      	  String reloadUrl;
      	  for (Photo photo : photos) {
      		reloadUrl = serviceManager.getAlbumCoverImageUrl(photo);      		
        	String firstClass = "";
        	String lastClass = "";
        	if (count == 0) {
          		firstClass = "first";
        	}
        	if (count == photos.size() - 1) {
          		lastClass = "last";
        	}
        	if (photos.size()!=0)
        	{; // show a picture only if there is at least one in the list
    	%>
    		<div class="feed <%= firstClass %> <%= lastClass %>"  
    			onclick="selectCover( <%= Integer.toString(count + 1) %>, '<%= reloadUrl%>')">
      			<div class="post group">
        			<div class="image-wrap">
          				<img class="photo-image"
            				src="<%= serviceManager.getImageDownloadUrl(photo)%>"
            				alt="Photo Image" />
        			</div>
        			<div class="owner group">
          			<!-- MM: took out here code for cats images -->
          				<div class="desc">
           				<h3>
            					<%= ServletUtils.getProtectedUserNickname(photo.getOwnerNickname()) %></h3>          
            				<p class="timestamp"><%= ServletUtils.formatTimestamp(photo.getUploadTime()) %></p>
            				<p>
            				<p><c:out value="<%= photo.getTitle() %>" escapeXml="true"/>
           					<img class="check" src="img/check.png" 
    							onload="isAlbumCover( <%= Integer.toString(count + 1) %>, <%= photo.isAlbumCover() %>)"
           						id=<%= ServletUtils.REQUEST_PARAM_NAME_COVER_ID.concat(Integer.toString(count + 1)) %> />         				
          			</div>
       				<!-- /.desc -->
        		</div>
        		<!-- /.usr -->
      		</div>
      		<!-- /.post -->
    	</div>
    	<!-- /.feed -->
   	<%
	}
        	count++;
      	}
      	
       if (count ==3) { %>   	
	
 
      	<%-- MM:the More pictures button after the 3 shown pictures --%>
        <div class="next-3-pict">
        	<form action="<%= serviceManager.getViewUrl(null, streamUserId, null, 
		 			                                       albm.getId().toString(), 
		 			                                       ServletUtils.REQUEST_PARAM_NAME_VIEW_STREAM, String.valueOf(start_with_photo+3))
		 			 %>"
                 method="post">    
                   <input id="btn-post" class="active btn" type="submit" value="More pictures">
            </form>
        </div>
    		<%-- MM: we enable the user to pick up a picture to add to the stream --%>
		<% } %>
		
    	<a id="btn-choose-image" class="active btn" href="Map.jsp?user=<%=(streamUserId + "&stream-id=" + streamId) %>">Geo view</a>
    	
        <div class="container">
            <br>
            <!-- The file upload form used as target for the file upload widget -->
            <form id="fileupload" action="<%= serviceManager.getUploadUrl(true)%>" method="POST" enctype="multipart/form-data">
              	<input type="hidden" name="stream-id" value="<%= streamId%>">
                <!-- The fileupload-buttonbar contains buttons to add/delete files and start/cancel the upload -->
                <div class="row fileupload-buttonbar">
                    <div class="span7">
                        <!-- The fileinput-button span is used to style the file input field as button -->
                        <span class="btn btn-success fileinput-button">
                            <i class="icon-plus icon-white"></i>
                            <span>Add files...</span>
                            <input type="file" name="files[]" multiple>
                        </span>
                        <button type="submit" class="btn btn-primary start">
                            <i class="icon-upload icon-white"></i>
                            <span>Start upload</span>
                        </button>
                        <button type="reset" class="btn btn-warning cancel">
                            <i class="icon-ban-circle icon-white"></i>
                            <span>Cancel upload</span>
                        </button>
                        <button type="button" class="btn btn-danger delete">
                            <i class="icon-trash icon-white"></i>
                            <span>Delete</span>
                        </button>
                        <input type="checkbox" class="toggle">
                    </div>
                    <!-- The global progress information -->
                    <div class="span5 fileupload-progress fade">
                        <!-- The global progress bar -->
                        <div class="progress progress-success progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100">
                            <div class="bar" style="width:0%;"></div>
                        </div>
                        <!-- The extended global progress information -->
                        <div class="progress-extended">&nbsp;</div>
                    </div>
                </div>
                <!-- The loading indicator is shown during file processing -->
                <div class="fileupload-loading"></div>
                <br>
                <!-- The table listing the files available for upload/download -->
                <table role="presentation" class="table table-striped"><tbody class="files" data-toggle="modal-gallery" data-target="#modal-gallery"></tbody></table>
            </form>
        </div>

        <!-- The template to display files available for upload -->
        <script id="template-upload" type="text/x-tmpl">
            {% for (var i=0, file; file=o.files[i]; i++) { %}
        <tr class="template-upload fade">
            <td class="preview"><span class="fade"></span></td>
            <td class="name"><span>{%=file.name%}</span></td>
            <td class="size"><span>{%=o.formatFileSize(file.size)%}</span></td>
            {% if (file.error) { %}
            <td class="error" colspan="2"><span class="label label-important">Error</span> {%=file.error%}</td>
            {% } else if (o.files.valid && !i) { %}
            <td>
                <div class="progress progress-success progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><div class="bar" style="width:0%;"></div></div>
            </td>
            <td class="start">{% if (!o.options.autoUpload) { %}
                <button class="btn btn-primary">
                    <i class="icon-upload icon-white"></i>
                    <span>Start</span>
                </button>
                {% } %}</td>
            {% } else { %}
            <td colspan="2"></td>
            {% } %}
            <td class="cancel">{% if (!i) { %}
                <button class="btn btn-warning">
                    <i class="icon-ban-circle icon-white"></i>
                    <span>Cancel</span>
                </button>
                {% } %}</td>
        </tr>
        {% } %}
    </script>
    <!-- The template to display files available for download -->
    <script id="template-download" type="text/x-tmpl">
        {% for (var i=0, file; file=o.files[i]; i++) { %}
        <tr class="template-download fade">
            {% if (file.error) { %}
            <td></td>
            <td class="name"><span>{%=file.name%}</span></td>
            <td class="size"><span>{%=o.formatFileSize(file.size)%}</span></td>
            <td class="error" colspan="2"><span class="label label-important">Error</span> {%=file.error%}</td>
            {% } else { %}
            <td class="preview">{% if (file.thumbnail_url) { %}
                <a href="{%=file.url%}" title="{%=file.name%}" rel="gallery" download="{%=file.name%}"><img src="{%=file.thumbnail_url%}"></a>
                {% } %}</td>
            <td class="name">
                <a href="{%=file.url%}" title="{%=file.name%}" rel="{%=file.thumbnail_url&&'gallery'%}" download="{%=file.name%}">{%=file.name%}</a>
            </td>
            <td class="size"><span>{%=o.formatFileSize(file.size)%}</span></td>
            <td colspan="2"></td>
            {% } %}
            <td class="delete">
                <button class="btn btn-danger" data-type="{%=file.delete_type%}" data-url="{%=file.delete_url%}"{% if (file.delete_with_credentials) { %} data-xhr-fields='{"withCredentials":true}'{% } %}>
                        <i class="icon-trash icon-white"></i>
                    <span>Delete</span>
                </button>
                <input type="checkbox" name="delete" value="1">
            </td>
        </tr>
        {% } %}
    </script>

    <script src="js/jquery-1.8.2.min.js"></script>
    <script src="js/vendor/jquery.ui.widget.js"></script>
    <script src="js/tmpl.min.js"></script>
    <script src="js/load-image.min.js"></script>
    <script src="js/canvas-to-blob.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/bootstrap-image-gallery.min.js"></script>
    <script src="js/jquery.iframe-transport.js"></script>
    <script src="js/jquery.fileupload.js"></script>
    <script src="js/jquery.fileupload-fp.js"></script>
    <script src="js/jquery.fileupload-ui.js"></script>
    <script src="js/locale.js"></script>
    <script src="js/main.js"></script>
      
    <%    
	}
	%>
    </div> <!-- /container -->
	
</body>
</html>