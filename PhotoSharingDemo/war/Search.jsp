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

   <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
    <script src="../../bootstrap/js/bootstrap.min.js"></script>

<!-- Custom styles for this template -->
<link href="navbar.css" rel="stylesheet">

<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
<script type="text/javascript"  src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>

  <script type="text/javascript">
  $(function() {
    var cache = {};
    $( "#search_txt" ).autocomplete({
      minLength: 1,
      source: function( request, response ) {
        var term = request.term;
        if ( term in cache ) {
          response( cache[ term ] );
          return;
        }
 
        $.getJSON( "/AutocompleteServletAPI", request, function( data, status, xhr ) {
          cache[ term ] = data;
          response( data );
        });
      }
    });
  });

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
            <li><a href="Connexus.jsp">View</a></li>
            <li class="active"><a href="Search.jsp">Search</a></li>
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

    <%--MM: should ask for what to search and allow the push of the "Search" button --%>
      <div class="view-title">
        <p>SEARCH STREAMS</p>
          <div  class="ui-widget">
            <form action="<%= configManager.getSearchAlbumUrl()%>"
             method="post">
               <input id="search_txt" class="input text" name="stream" type="text" value="search name here...">
               <input id="btn-post" class="active btn" type="submit" name="Search" value="Search">
               <input id="btn-post" class="active btn" type="submit" name="Rebuild" value="Rebuild completion index">
            </form>
          </div>
          <% 
          String search_text = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_SEARCH_TXT);
          if (search_text != null) {   		  
        	  	Iterable<Album> albumIter = albumManager.getActiveAlbums();
  				ArrayList<Album> albums = new ArrayList<Album>();
  				try {
    				for (Album album : albumIter) {
        				if ((album.getTitle()).indexOf(search_text) != -1) {albums.add(album); }
        				else 
        					if ((album.getTags()!=null)&& (album.getTags()).indexOf(search_text) != -1) {albums.add(album);}
        			}
  				} catch (DatastoreNeedIndexException e) {
        			pageContext.forward(configManager.getErrorPageUrl(
         			 ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
  				}   	
  			//}	
          //if (search_text != null) {   		  
          	int count = 0;
	      	for (Album album : albums) {
	      		Photo coverPhoto = null;
	      		String coverPhotoUrl = null;
	          	Iterable<Photo> photoIter = photoManager.getOwnedAlbumPhotos(album.getOwnerId().toString(), album.getId().toString());
	          	try {
	            	for (Photo photo : photoIter) {
		          		if(photo.isAlbumCover())
		          			coverPhoto = photo;
	            	}
	          	} catch (DatastoreNeedIndexException e) {
	            	pageContext.forward(configManager.getErrorPageUrl(
	              		ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
	          	}
				if(coverPhoto == null)
					coverPhotoUrl = ServletUtils.getUserIconImageUrl(album.getOwnerId());
				else
					coverPhotoUrl = serviceManager.getImageDownloadUrl(coverPhoto);	    	  
	%>
      		<div class="feed">
	      		<div class="post group">
		        	<div class="image-wrap">
		        		<a href="<%= serviceManager.getViewUrl(null, album.getOwnerId(), null, 
				 				album.getId().toString(), 
				 			 	ServletUtils.REQUEST_PARAM_NAME_VIEW_STREAM, null) %>"> 
		          		<img class="photo-image"
		            		src="<%= coverPhotoUrl%>"
			 			 	alt="Photo Image" /></a>
	        		</div>
		        	<div class="owner group">
		          		<div class="desc">
		            		<h3><%= ServletUtils.getProtectedUserNickname(album.getOwnerNickname()) %></h3>	            
		            		<p class="timestamp"><%= ServletUtils.formatTimestamp(album.getUploadTime()) %></p>
		            		<p>
		            		<p><c:out value="<%= album.getTitle() %>" escapeXml="true"/>
		          		</div>
        			</div>
	      		</div>
   			</div>
	<%	
				count++;
				if (count ==2) break;
      		}
          }
    %>
     </div>
    </div> <!-- /container -->

 
</body>
</html>