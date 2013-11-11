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
            <li><a href="Manage.jsp">Manage</a></li>
            <li><a href="Create.jsp">Create</a></li>
            <li><a href="Connexus.jsp">View</a></li>
            <li><a href="Search.jsp">Search</a></li>
            <li class="active"><a href="Trending.jsp">Trending</a></li>
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
                  <a href=<%= userService.createLoginURL(configManager.getTrendingPageUrl())%>>Sign in</a>   
   			<% } %>  
    		</li>
          </ul>
        </div><!--/.nav-collapse -->
      </div>

      <div class="view-title">
        <p>TOP 3 TRENDING STREAMS</p>
      </div>
         	<%
          	String radio_choice = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_SEARCH_TXT);
            %>     
      <%
      //boolean ff = false;
      //if(ff)
      {
   	  ArrayList<Album> albums = new ArrayList<Album>();
      Album albm = null;
      Long albId = leaderboardManager.getLeaderboardEntry("EntryA").getAlbumId();
      String usrId = leaderboardManager.getLeaderboardEntry("EntryA").getUserId();
      long a = leaderboardManager.getLeaderboardEntry("EntryA").getViewsNumber();
      if(albId != 0 && usrId != null) {
      	albm = albumManager.getAlbum(usrId, albId.longValue());
      	if(albm != null)
      		albums.add(albm);
      }
      albId = leaderboardManager.getLeaderboardEntry("EntryB").getAlbumId();
      usrId = leaderboardManager.getLeaderboardEntry("EntryB").getUserId();
      long b= leaderboardManager.getLeaderboardEntry("EntryB").getViewsNumber();
      if(albId != 0 && usrId != null) {
        	albm = albumManager.getAlbum(usrId, albId.longValue());
        	if(albm != null)
        		albums.add(albm);
        }
      albId = leaderboardManager.getLeaderboardEntry("EntryC").getAlbumId();
      usrId = leaderboardManager.getLeaderboardEntry("EntryC").getUserId();
      long c= leaderboardManager.getLeaderboardEntry("EntryC").getViewsNumber();
      if(albId != 0 && usrId != null) {
        	albm = albumManager.getAlbum(usrId, albId.longValue());
        	if(albm != null)
        		albums.add(albm);
        }
	  long nv;
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
		if (count ==0) nv=a; else if (count ==1) nv=b; else nv=c;
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
		            		<p><%= String.valueOf(nv)%> views past hour.</p>
		            		<p>
		            		<p><c:out value="<%= album.getTitle() %>" escapeXml="true"/>
		          		</div>
		          		<!-- /.desc -->
        			</div>
		        	<!-- /.usr -->
	      		</div>
	      		<!-- /.post -->
   			</div>
    		<!-- /.feed -->
	<%	
			count++;
	if (count ==3) break;
      	}
      }
    %>
       	<div class = box >	
  		</div>
         <div class="next-3-pict" >
                 <%-- MCM: replace action form with update rate --%>
        	<form   
               action="<%= configManager.getSetCronTimeUrl() %>"method="post"> 
      		<tr>   		    
                 <td><input type="radio" name="course" value="no_reports">No reports</td><p></p>
                 <td><input type="radio" name="course" value="five_min">Every 5 minutes</td><p></p>
                 <td><input type="radio" name="course" value="one_hour">Every 1 hour </td><p></p>
                 <td><input type="radio" name="course" value="every_day">Every day </td><p></p>
     		</tr>
            <tr> Email trending report </tr>
              <input id="btn-post" class="active btn" type="submit" value="Update Rate">
            </form>
       </div>
    </div> <!-- /container -->

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
    <script src="../../bootstrap/js/bootstrap.min.js"></script>

</body>
</html>