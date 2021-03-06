/*
 * Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.cloud.demo;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.blobstore.UploadOptions;
import com.google.appengine.api.files.AppEngineFile;
import com.google.appengine.api.files.FileService;
import com.google.appengine.api.files.FileServiceFactory;
import com.google.appengine.api.files.FileStat;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.images.ImagesServiceFailureException;
import com.google.appengine.api.images.ServingUrlOptions;
import com.google.cloud.demo.model.Photo;
import com.google.cloud.demo.model.PhotoManager;

import java.io.FileNotFoundException;
import java.util.logging.Logger;

/**
 * The main service class providing some helper method for photo management.
 *
 * @author Michael Tang (ntang@google.com)
 */
public class PhotoServiceManager {
  private static final Logger logger =
      Logger.getLogger(PhotoServiceManager.class.getCanonicalName());
  private ConfigManager configManager;
  private PhotoManager photoManager;

  public PhotoServiceManager(ConfigManager configManager, PhotoManager photoManager) {
    this.configManager = configManager;
    this.photoManager = photoManager;
  }

  public String getUploadUrl(boolean multiple) {
	    BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	    UploadOptions uploadOptions = null;
	    String bucket = configManager.getGoogleStorageBucket();
	    
	    /////////////////////////////////////////////   
	    bucket = null; //MM: force it to work without GCS for now
	    /////////////////////////////////////////////
	    
	    if (bucket == null || bucket.isEmpty()) {
	      uploadOptions = UploadOptions.Builder.withDefaults();
	    } else {
	      uploadOptions = UploadOptions.Builder.withGoogleStorageBucketName(bucket);
	    }
	    String handler = configManager.getUploadHandlerUrl();
	    if(multiple)
	    	handler = "/UploadServlet";
	    String createdUrl = blobstoreService.createUploadUrl(handler, uploadOptions);
	    String retUrl = StripUrlFromParameters(createdUrl);
        System.out.println(retUrl);
        System.out.println(createdUrl);
	    return createdUrl;
	    //return retUrl;
	  }

  public String getCreateAlbumCoverUrl() {
	    BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	    UploadOptions uploadOptions = null;
	    String bucket = configManager.getGoogleStorageBucket();
	    
	    /////////////////////////////////////////////   
	    bucket = null; //MM: force it to work without GCS for now
	    /////////////////////////////////////////////
	    
	    if (bucket == null || bucket.isEmpty()) {
	      uploadOptions = UploadOptions.Builder.withDefaults();
	    } else {
	      uploadOptions = UploadOptions.Builder.withGoogleStorageBucketName(bucket);
	    }
	    String createdUrl = blobstoreService.createUploadUrl(configManager.getCreateAlbumUrl(), uploadOptions);
	    String retUrl = StripUrlFromParameters(createdUrl);
	    return createdUrl;
	  }

	  private String StripUrlFromParameters(String createdUrl)
	  {
		  //createdUrl = "http://balaurbun2013.appspot.com/_ah/upload/?user=118090058030877094640&stream-id=5118776383111168&tabId=viewstream/AMmfu6ZKQwzrU5ADi7hJe-nef6TBKXeqKObGNOlHySg0gZFRJj63WuFj-tYbktYtwqdZbLnaZcbAC6dRVWUtbnfeXx_XRslsqfgKM4lMXymCxKbZBk5yNgOKNLRRAbcl7UJ06je4zOAA/ALBNUaYAAAAAUkQcfuvOOrmVEyMcLWgOhqpdE-XXW0QF/";
		  String retUrl = null;
		  int mark = createdUrl.lastIndexOf('?');
		  if(mark == -1)
			  retUrl = createdUrl;
		  else {
			  int slash = createdUrl.indexOf('/', mark);
			  if(slash != -1) {
				  int end = createdUrl.length();
				  String blob_part = createdUrl.substring(slash+1, end);
				  String hostUrl = createdUrl.substring(0, mark);
				  retUrl = hostUrl.concat(blob_part);
			  }
		  }
		  return retUrl;
	  }
  
  public String getThumbnailUrl(BlobKey blobKey) {
    ServingUrlOptions options = ServingUrlOptions.Builder.withBlobKey(blobKey);
    options.imageSize(configManager.getPhotoThumbnailSizeInPixels());
    options.crop(configManager.isPhotoThumbnailCrop());
    try {
      return ImagesServiceFactory.getImagesService().getServingUrl(options);
    } catch (ImagesServiceFailureException e) {
      logger.severe("Failed to get image serving url: " + e.getMessage());
      return "";
    } catch (Exception e) {
      logger.severe("Invalid blob key: " + e.getMessage());
      return "";
    }
  }

  public String getPhotoDisplayUrl(BlobKey blobKey) {
    ServingUrlOptions options = ServingUrlOptions.Builder.withBlobKey(blobKey);
    options.imageSize(configManager.getPhotoDisplaySizeInPixels());
    options.crop(configManager.isPhotoThumbnailCrop());
    try {
      return ImagesServiceFactory.getImagesService().getServingUrl(options);
    } catch (ImagesServiceFailureException e) {
      logger.severe("Failed to get image serving url: " + e.getMessage());
      return "";
    }
  }

  /**
   * Gets the photo menu link url.
   *
   * @param targetUrl the target page url.
   * @param photo the photo object.
   * @return a photo url string.
   */
  public String getMenuLinkUrl(String targetUrl, Photo photo) {
    if (targetUrl == null) {
      targetUrl = configManager.getMainPageUrl();
    }
    return new StringBuilder(targetUrl).append("?")
        .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
        .append("=")
        .append(photo.getId())
        .append("&")
        .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
        .append("=")
        .append(photo.getOwnerId()).toString();
  }

  public String getImageDownloadUrl(Photo photo) {
	    return new StringBuilder(configManager.getDownloadHandlerUrl()).append("?")
	        .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
	        .append("=")
	        .append(photo.getId())
	        .append("&")
	        .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
	        .append("=")
	        .append(photo.getOwnerId()).toString();
	  }
  
  public String getAlbumCoverImageUrl(Photo photo) {
	  	StringBuilder builder = new StringBuilder(configManager.getAlbumCoverUrl());

	  	builder.append("?")
	        .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
	        .append("=")
	        .append(photo.getId())
	        .append("&")
	        .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
	        .append("=")
	        .append(photo.getOwnerId()).toString();
	    return builder.toString();
	  }

  /**
   * Constructs a redirect url to specific photo. if the photo information is not available, return
   * to the main page.
   *
   * @param targetUrl target url. If null,
   * @param userId the photo owner id
   * @param id the photo id.
   * @param next_three_photos starting with which three pictures to show now
   *
   * @return the url string to the main page.
   */
  public String getRedirectUrl(String targetUrl, String userId, String id, String albumId, String tabId, String which_photos) {
    if (targetUrl == null) {
      targetUrl = configManager.getMainPageUrl();
    }
    StringBuilder builder = new StringBuilder(targetUrl);
    if (userId != null) {
      builder.append("?")
          .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
          .append("=")
          .append(userId);
    }
    if(id != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
          .append("=")
          .append(id);	
    }
    if(albumId != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID)
          .append("=")
          .append(albumId);	
    }
    if (tabId != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_TAB_ID)
	      .append("=")
	      .append(tabId);
    }
    if (which_photos != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_LOC)
	      .append("=")
	      .append(which_photos);
    }
    return builder.toString();
  }
  
  /**
   * Constructs a redirect url to specific photo. if the photo information is not available, return
   * to the main page.
   *
   * @param targetUrl target url. If null,
   * @param userId the photo owner id
   * @param id the photo id.
   * @param next_three_photos starting with which three pictures to show now
   *
   * @return the url string to the main page.
   */
  public String getAlbumCovertUrl(String targetUrl, String userId, String id, String albumId, String tabId, String which_photos) {
    if (targetUrl == null) {
      targetUrl = configManager.getViewPageUrl();
    }
    StringBuilder builder = new StringBuilder(targetUrl);
    if (userId != null) {
      builder.append("?")
          .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
          .append("=")
          .append(userId);
    }
    if(id != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
          .append("=")
          .append(id);	
    }
    if(albumId != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID)
          .append("=")
          .append(albumId);	
    }
    if (tabId != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_TAB_ID)
	      .append("=")
	      .append(tabId);
    }
    if (which_photos != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_LOC)
	      .append("=")
	      .append(which_photos);
    }
    return builder.toString();
  }
  
  /**
   * Constructs a redirect url to specific photo. if the photo information is not available, return
   * to the main page.
   *
   * @param targetUrl target url. If null,
   * @param userId the photo owner id
   * @param id the photo id.
   * @param next_three_photos starting with which three pictures to show now
   *
   * @return the url string to the main page.
   */
  public String getCreateUrl(String targetUrl, String userId, String id, String albumId, String tabId, String which_photos) {
    if (targetUrl == null) {
      targetUrl = configManager.getCreatePageUrl();
    }
    StringBuilder builder = new StringBuilder(targetUrl);
    if (userId != null) {
      builder.append("?")
          .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
          .append("=")
          .append(userId);
    }
    if(id != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
          .append("=")
          .append(id);	
    }
    if(albumId != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID)
          .append("=")
          .append(albumId);	
    }
    if (tabId != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_TAB_ID)
	      .append("=")
	      .append(tabId);
    }
    if (which_photos != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_LOC)
	      .append("=")
	      .append(which_photos);
    }
    return builder.toString();
  }
  
  /**
   * Constructs a redirect url to specific photo. if the photo information is not available, return
   * to the main page.
   *
   * @param targetUrl target url. If null,
   * @param userId the photo owner id
   * @param id the photo id.
   * @param next_three_photos starting with which three pictures to show now
   *
   * @return the url string to the main page.
   */
  public String getManageUrl(String targetUrl, String userId, String id, String albumId, String tabId, String which_photos) {
    if (targetUrl == null) {
      targetUrl = configManager.getManagePageUrl();
    }
    StringBuilder builder = new StringBuilder(targetUrl);
    if (userId != null) {
      builder.append("?")
          .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
          .append("=")
          .append(userId);
    }
    if(id != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
          .append("=")
          .append(id);	
    }
    if(albumId != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID)
          .append("=")
          .append(albumId);	
    }
    if (tabId != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_TAB_ID)
	      .append("=")
	      .append(tabId);
    }
    if (which_photos != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_LOC)
	      .append("=")
	      .append(which_photos);
    }
    return builder.toString();
  }
  
  /**
   * Constructs a redirect url to specific photo. if the photo information is not available, return
   * to the main page.
   *
   * @param targetUrl target url. If null,
   * @param userId the photo owner id
   * @param id the photo id.
   * @param next_three_photos starting with which three pictures to show now
   *
   * @return the url string to the main page.
   */
  public String getViewUrl(String targetUrl, String userId, String id, String albumId, String tabId, String which_photos) {
    if (targetUrl == null) {
      targetUrl = configManager.getViewPageUrl();
    }
    StringBuilder builder = new StringBuilder(targetUrl);
    if (userId != null) {
      builder.append("?")
          .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
          .append("=")
          .append(userId);
    }
    if(id != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
          .append("=")
          .append(id);	
    }
    if(albumId != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID)
          .append("=")
          .append(albumId);	
    }
    if (tabId != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_TAB_ID)
	      .append("=")
	      .append(tabId);
    }
    if (which_photos != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_LOC)
	      .append("=")
	      .append(which_photos);
    }
    return builder.toString();
  }
  
  /**
   * Constructs a redirect url to specific photo. if the photo information is not available, return
   * to the main page.
   *
   * @param targetUrl target url. If null,
   * @param userId the photo owner id
   * @param id the photo id.
   * @param next_three_photos starting with which three pictures to show now
   *
   * @return the url string to the main page.
   */
  public String getSubscribeUrl(String targetUrl, String userId, String id, String albumId, String tabId, String subscribe) {
    if (targetUrl == null) {
      targetUrl = configManager.getViewPageUrl();
    }
    StringBuilder builder = new StringBuilder(targetUrl);
    if (userId != null) {
      builder.append("?")
          .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
          .append("=")
          .append(userId);
    }
    if(id != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
          .append("=")
          .append(id);	
    }
    if(albumId != null) {
    	builder.append("&")  	 
    	  .append(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID)
          .append("=")
          .append(albumId);	
    }
    if (tabId != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_TAB_ID)
	      .append("=")
	      .append(tabId);
    }
    if (subscribe != null) {
    	builder.append("&")
    	  .append(ServletUtils.REQUEST_PARAM_NAME_SUBSCRIBE)
	      .append("=")
	      .append(subscribe);
    }
    return builder.toString();
  }
  
  public String getSearchUrl(String targetUrl, String userId, String id, String albumId, String tabId, String which_photos, String search_text) {
	    if (targetUrl == null) {
	      targetUrl = configManager.getSearchPageUrl();
	    }
	    StringBuilder builder = new StringBuilder(targetUrl);
	      builder.append("?");
	    if ( search_text != null) {
	    	builder.append(ServletUtils.REQUEST_PARAM_NAME_SEARCH_TXT)
		      .append("=")
		      .append(search_text);
	    if (userId != null) {
	    	  builder.append("&")
	    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_OWNER_ID)
	          .append("=")
	          .append(userId);
	    }
	    if(id != null) {
	    	builder.append("&")  	 
	    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_ID)
	          .append("=")
	          .append(id);	
	    }
	    if(albumId != null) {
	    	builder.append("&")  	 
	    	  .append(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID)
	          .append("=")
	          .append(albumId);	
	    }
	    if (tabId != null) {
	    	builder.append("&")
	    	  .append(ServletUtils.REQUEST_PARAM_NAME_TAB_ID)
		      .append("=")
		      .append(tabId);
	    }
	    if (which_photos != null) {
	    	builder.append("&")
	    	  .append(ServletUtils.REQUEST_PARAM_NAME_PHOTO_LOC)
		      .append("=")
		      .append(which_photos);
	    }
	    }
	    return builder.toString();
	  }

  public void cleanDeactivedPhotos() {
    Iterable<Photo> photos = photoManager.getDeactivedPhotos();
    if (photos != null) {
      for (Photo photo : photos) {
        removeDeactivedPhoto(photo);
      }
    }
  }
  private void removeDeactivedPhoto(Photo photo) {
    if (photo != null && !photo.isActive()) {
      try {
        FileService fileService = FileServiceFactory.getFileService();
        BlobKey blobKey = photo.getBlobKey();
        AppEngineFile file = fileService.getBlobFile(blobKey);
        FileStat stat = fileService.stat(file);
        if (stat != null) {
          logger.fine("photo:" + photo.getId() + " blob file stat is not null");
          BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
          blobstoreService.delete(blobKey);
          logger.info("The blob is deleted. try to delete the entity from datastore.");
          photoManager.deleteEntity(photo);
        }
      } catch (FileNotFoundException e) {
        logger.info("The blob is alrady deleted. try to delete the entity from datastore.");
        photoManager.deleteEntity(photo);
      } catch (Exception e) {
        logger.severe("Failed to delete the blob storge for photo " + photo.getId() +
            ":" + e.getMessage());
      }
    }
  }
}
