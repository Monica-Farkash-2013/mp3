package com.google.cloud.demo.model.nosql;

import static com.google.appengine.api.datastore.DatastoreServiceFactory.getDatastoreService;

import java.util.logging.Logger;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Transaction;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.cloud.demo.model.Album;
import com.google.cloud.demo.model.AlbumManager;
import com.google.cloud.demo.model.Photo;
import com.google.cloud.demo.model.Utils;

public class AlbumManagerNoSql extends DemoEntityManagerNoSql<Album> implements	AlbumManager {
	  private static final Logger logger = Logger.getLogger(PhotoManagerNoSql.class.getCanonicalName());
	  private DemoUserManagerNoSql userManager;
	  private PhotoManagerNoSql photoManager;

	  public AlbumManagerNoSql(DemoUserManagerNoSql userManager, PhotoManagerNoSql photoManager) {
	    super(Album.class);
	    this.userManager = userManager;
	    this.photoManager = photoManager;
	  }

	  @Override
	  public AlbumNoSql fromParentKey(Key parentKey) {
	    return new AlbumNoSql(parentKey, getKind());
	  }

	  @Override
	  public AlbumNoSql newAlbum(String userId) {
	    return new AlbumNoSql(userManager.createDemoUserKey(userId), getKind());
	  }

	  @Override
	  protected AlbumNoSql fromEntity(Entity entity) {
	    return new AlbumNoSql(entity);
	  }
	  
	@Override
	public Album deleteEntity(Album entity) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Album getAlbum(String userId, long id) {
	    Key key = createAlbumKey(userId, id);
	    return getEntity(key);
	}

	public Key createAlbumKey(String userId, Long id) {
	    Utils.assertTrue(id != null, "id cannot be null");
	    if (userId != null) {
	      Key parentKey = userManager.createDemoUserKey(userId);
	      return KeyFactory.createKey(parentKey, getKind(), id);
	    } else {
	      return KeyFactory.createKey(getKind(), id);
	    }
	}

	@Override
	public Iterable<Album> getOwnedAlbums(String userId) {
	    Query query = new Query(getKind());
	    query.setAncestor(userManager.createDemoUserKey(userId));
	    Query.Filter filter = new Query.FilterPredicate(AlbumNoSql.FIELD_NAME_ACTIVE,
	        FilterOperator.EQUAL, true);
	    query.setFilter(filter);
	    FetchOptions options = FetchOptions.Builder.withDefaults();
	    return queryEntities(query, options);
	}

	@Override
	public Iterable<Album> getSharedAlbums(String userId) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Iterable<Album> getDeactivedAlbums() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Iterable<Album> getActiveAlbums() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Album deactiveAlbum(String userId, long id) {
	    Utils.assertTrue(userId != null, "user id cannot be null");
	    photoManager.deactivateAlbumPhotos(userId, id);
	    DatastoreService ds = getDatastoreService();
	    Transaction txn = ds.beginTransaction();
	    try {
	      Entity entity = getDatastoreEntity(ds, createAlbumKey(userId, id));
	      if (entity != null) {
	        AlbumNoSql album = new AlbumNoSql(entity);
	        if (album.isActive()) {
	        	album.setActive(false);
	          ds.put(entity);
	        }
	        txn.commit();

	        return album;
	      }
	    } catch (Exception e) {
	      logger.severe("Failed to delete entity from datastore:" + e.getMessage());
	    } finally {
	      if (txn.isActive()) {
	        txn.rollback();
	      }
	    }
	    return null;
	}

}
