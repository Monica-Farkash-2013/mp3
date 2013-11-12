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
<title>Insert title here</title>
<!-- Bootstrap core CSS -->
<link href="../../bootstrap/css/bootstrap.css" rel="stylesheet">

<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script> 
<script type="text/javascript" src="js/demos/js/jquery-1.7.1/jquery.min.js"></script>
<script type="text/javascript" src="js/demos/js/underscore-1.2.2/underscore.min.js"></script>
<script type="text/javascript" src="js/demos/js/backbone-0.5.3/backbone.min.js"></script>
<script type="text/javascript" src="js/demos/js/prettify/prettify.min.js"></script>
<script type="text/javascript" src="js/demos/js/demo.js"></script>
<script type="text/javascript" src="js/demos/js/markerclustererplus-2.0.6/markerclusterer.min.js"></script>
<script type="text/javascript" src="js/ui/jquery.ui.map.js"></script>

<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
<script type="text/javascript"  src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>

<!-- Bootstrap core JavaScript
================================================== -->
<!-- Placed at the end of the document so the pages load faster -->
<script src="../../bootstrap/js/bootstrap.min.js"></script>

<!-- Custom styles for this template -->
<link href="navbar.css" rel="stylesheet">


<%
	String streamId = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID); 
	String streamUserId = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID);
%>

<script type="text/javascript">
var begin = new Date();
var finish = new Date();

$(function() { 
		demo.add(function() {
			$('#map_canvas').gmap({'zoom': 2, 'disableDefaultUI':true}).bind('init', function(evt, map) { 
			    var items = [];
			    var stam = 0;
				var bounds = map.getBounds();
				var southWest = bounds.getSouthWest();
				var northEast = bounds.getNorthEast();
				var lngSpan = northEast.lng() - southWest.lng();
				var latSpan = northEast.lat() - southWest.lat();

				$.getJSON( "/SingleStreamServletAPI?user=<%=(streamUserId + "&stream-id=" + streamId) %>", function(data) {
					data.forEach( function(item) {
						items.push(item);
						stam++;
					});
				});
				for ( var i = 0; i < 1000; i++ ) {
					var lat = southWest.lat() + latSpan * Math.random();
					var lng = southWest.lng() + lngSpan * Math.random();
					$(this).gmap('addMarker', { 
						'position': new google.maps.LatLng(lat, lng) 
					} ).mouseover(function() {
						
						var index = Math.round(1000  * Math.random()) % stam;
						var pictureDate = new Date(items[index].createDate);
						if(pictureDate.getTime() < begin.getTime() || pictureDate.getTime() > finish.getTime())
							$('#map_canvas').gmap('openInfoWindow', { content : '<img src="img/photofeed.png"/> <p class="timestamp">' +
								'Date out of range' + '</p>'}, this);
						else
							$('#map_canvas').gmap('openInfoWindow', { content : '<img class="photo-map" src='+items[index].bkUrl+
								' /> <p class="timestamp">'  +items[index].createDate + '</p>'}, this);
					});
				} 
				$(this).gmap('set', 'MarkerClusterer', new MarkerClusterer(map, $(this).gmap('get', 'markers')));
			});
		}).load();
	});

	$(function() {
		var endDate = finish.getTime(); 
		var startDate = endDate - 365*24*60*60*1000;
		begin.setTime(startDate);
	
	    $('#slider-range' ).slider({
	      range: true,
	      min: Math.round(startDate/(24*60*60*1000)),
	      max: Math.round(endDate/(24*60*60*1000)),
	      values: [ Math.round(startDate/(24*60*60*1000)), Math.round(endDate/(24*60*60*1000)) ],
	      slide: function( event, ui ) {
	    	  begin.setTime(ui.values[ 0 ]*24*60*60*1000);
	    	  finish.setTime(ui.values[ 1 ]*24*60*60*1000);

	        $( "#amount" ).val( "From: " + begin.toString() + " to: " + finish.toString() );
	      }
	    });
	    //$( "#amount" ).val( "From: " + $( "#slider-range" ).slider( "values", 0 ) +
	  	//      " to: " + $( "#slider-range" ).slider( "values", 1 ) );
	    $( "#amount" ).val( "From: " + begin.toString() + " to: " + finish.toString() );
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

		<p>
			<label for="amount">Time range:</label>
			<input type="text" id="amount" style="border: 0; color: #f6931f; font-weight: bold; width:1000px;" />
		</p>
		<div id="slider-range" style="width:1100px;"></div>
		<p></p>
		<div id="map_canvas" style="width:1100px;height:500px"></div>		
    </div> <!-- /container -->


</body>
</html>