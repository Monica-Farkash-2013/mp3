package com.google.cloud.demo;

import static com.googlecode.objectify.ObjectifyService.ofy;

import java.io.IOException;
import java.util.Enumeration;
import java.util.logging.Logger;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreNeedIndexException;
import com.google.cloud.demo.model.Album;
import com.google.cloud.demo.model.AlbumManager;

public class SearchAlbumServlet extends HttpServlet {


/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

@Override
  protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
    AppContext appContext = AppContext.getAppContext();
	ConfigManager configManager = appContext.getConfigManager();
    AlbumManager albumManager = appContext.getAlbumManager();
    String search_txt = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_STREAM);

    String button = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_SEARCH_BUTTON);
    if(button != null) {
		Iterable<Album> albumIter = albumManager.getActiveAlbums();

	  	try {
			for (Album album : albumIter) {
				Hints s = new Hints(album.getTags(), album.getTitle());
				if (!s.isAlreadyInList(s))
					// persist to datastore
					ofy().save().entity(s).now();
			}
		} catch (DatastoreNeedIndexException e) {
	        try {
				res.sendRedirect(configManager.getErrorPageUrl(
				  configManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
	  	}    	
    }

    res.sendRedirect(appContext.getPhotoServiceManager().getSearchUrl(
              req.getParameter(ServletUtils.REQUEST_PARAM_NAME_TARGET_URL), null, null, null, "searchstream", null,search_txt));
  }

}

