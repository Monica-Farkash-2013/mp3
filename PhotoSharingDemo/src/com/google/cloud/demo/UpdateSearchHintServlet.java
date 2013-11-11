/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.google.cloud.demo;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreNeedIndexException;
import com.google.cloud.demo.model.Album;
import com.google.cloud.demo.model.AlbumManager;

import static com.googlecode.objectify.ObjectifyService.ofy;

/**
 * Clean up deleted photos.
 *
 * @author Michael Tang (ntang@google.com)
 */
public class UpdateSearchHintServlet extends HttpServlet {
  /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

@Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
	    AppContext appContext = AppContext.getAppContext();
		ConfigManager configManager = appContext.getConfigManager();
	    AlbumManager albumManager = appContext.getAlbumManager();
	
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
				resp.sendRedirect(configManager.getErrorPageUrl(
				  configManager.ERROR_CODE_DATASTORE_INDEX_NOT_READY));
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
	  	}

  }
}
