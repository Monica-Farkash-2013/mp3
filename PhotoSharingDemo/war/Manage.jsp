
</html><%@ page language="java" contentType="text/html; charset=ISO-8859-1"
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

<!-- Custom styles for this template -->
<link href="navbar.css" rel="stylesheet">
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
            <li class="active"><a href="Manage.jsp">Manage</a></li>
            <li><a href="Create.jsp">Create</a></li>
            <li><a href="Connexus.jsp">View</a></li>
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
                  <a href=<%= userService.createLoginURL(configManager.getManagePageUrl())%>>Sign in</a>   
   			<% } %>  
    		</li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>

      <div class="view-title">
	        <p>MANAGE STREAMS</p>
	  <%
    	if	(currentUser != null) { 
	  %>
        <form action="<%= configManager.getManageAlbumsUrl() %>"
              method="post">     
	        <p>Streams I own:</p>
	        <table border="1">
			 <tr>
			 	<th>Name</th>
			 	<th>Last New Picture</th>
			 	<th>Number of Pictures</th>
			 	<th>Delete</th>
			 </tr>
		    <%
		      Iterable<Album> albumIter = albumManager.getOwnedAlbums(currentUser.getUserId());
		      ArrayList<Album> albums = new ArrayList<Album>();
		      try {
		        for (Album album : albumIter) {
		        	albums.add(album);
		        }
		      } catch (DatastoreNeedIndexException e) {
		        pageContext.forward(configManager.getErrorPageUrl(
		          ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
		      }
			  int table_count = 0;
		      for (Album album : albums) {
		    	  table_count++;
		    %>
				 <tr>
				 	<td><a href=<%= serviceManager.getViewUrl(null, currentUser.getUserId(), null, 
				 			album.getId().toString(), 
				 			 ServletUtils.REQUEST_PARAM_NAME_VIEW_STREAM, null) %>> <%= album.getTitle() %></a></td>
				 	<td><%= ServletUtils.formatTimestamp(photoManager.getNewestPhotoTimestamp(currentUser.getUserId(),album.getId().toString()))%></td>
				 	<td><%= photoManager.getAlbumSize(currentUser.getUserId(),album.getId().toString())%></td>
					<td><input type="checkbox" name="delete-box" value=<%= album.getId().toString() %>></td>
				 </tr>
			 <%	} %>
			 </table> 
			 <%
		      	String btn_type = "submit";
			 	if (table_count == 0) {
			 		btn_type = "hidden";
			 %>
	     	<p>Please create new streams...</p>			 
  			<%	} %>
	        <input id="delete-streams" class="active btn" type=<%= btn_type %> value="Delete Checked">
 	    </form>    
	  <% } else {%> 	
	     <p>Please login in order to manage your streams...</p>
	  <% } %>
	        
      </div>
      <div class="manage-subscribed">
	  <%	      
        if	(currentUser != null) { 
      %>
        <form action="<%= configManager.getManageAlbumsUrl() %>"
              method="post">
                <p>Streams I subscribe to:</p>
                <table border="1">
                         <tr>
                                <th>Name</th>
                                <th>Last New Picture</th>
                                <th>Number of Pictures</th>
                                <th>Views</th>
                                <th>Unsubscribe</th>
                         </tr>

                    <% 
                      Iterable<Subscription> subscriptions_Iter = subscriptionManager.getSubscriberAlbums(currentUser.getUserId().toString()); 
                      ArrayList<Album> sub_albums = new ArrayList<Album>();
                      try {
                        for (Subscription sub_scription : subscriptions_Iter) {
                        	Album sub_alb = albumManager.getAlbumS(currentUser.getUserId(), sub_scription.getAlbumId().toString());
                        	if(sub_alb != null)
                                sub_albums.add(sub_alb);
                        }
                      } catch (DatastoreNeedIndexException e) {
                        pageContext.forward(configManager.getErrorPageUrl(
                          ConfigManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
                      }
                      
        			  int table_count = 0;
                      for (Album sub_album : sub_albums) {
                    	table_count++;
                  		Iterable<View> albumViews = viewManager.getAlbumViews(sub_album.getId().toString());
                		long viewCount = 0;
                		for (View view : albumViews) {
                			viewCount++;
                		}
					%>
                                  <tr>
                                        <td><a href=<%= serviceManager.getSubscribeUrl(null, sub_album.getOwnerId(), null,
                                                        sub_album.getId().toString(),
                                                         ServletUtils.REQUEST_PARAM_NAME_VIEW_STREAM, "Subscribe") %>> <%= sub_album.getTitle() %></a></td>
                                        <td><%= ServletUtils.formatTimestamp(photoManager.getNewestPhotoTimestamp( sub_album.getOwnerId(), sub_album.getId().toString())) %></td>
                                        <td><%= photoManager.getAlbumSize(sub_album.getOwnerId(),sub_album.getId().toString())%></td>
                                        <td><%= viewCount%></td>
                                        <td><input type="checkbox" name="unsubscribe-box" value=<%= sub_album.getId().toString() %>></td>
                                 </tr>
                     <%     
                     }
                     %>
                         </table>
	 			 <%
			      	String btn_type = "submit";
				 	if (table_count == 0) {
				 		btn_type = "hidden";
				 %>
		     	<p>Please subscribe to new streams...</p>			 
	  			<%	} %>
                <input id="unsubscribe-streams" class="active btn" type=<%= btn_type%> value="Unsubscribe Checked">
            </form>     
      <% } %>
      </div>
    </div> <!-- /container -->


    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
    <script src="../../bootstrap/js/bootstrap.min.js"></script>

</body>
</html>