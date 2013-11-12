package com.google.cloud.demo;

import java.io.*;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.json.JSONArray;
import org.json.JSONObject;

import com.google.cloud.demo.model.DemoUser;
import com.google.cloud.demo.model.Photo;
import com.google.cloud.demo.model.PhotoManager;
import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.blobstore.FileInfo;
import com.google.appengine.api.images.Image;
import com.google.appengine.api.images.ImagesService;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.images.Transform;

@SuppressWarnings("serial")
public class UploadServlet extends HttpServlet {
        
	private static final Logger logger =
		      Logger.getLogger(UploadServlet.class.getCanonicalName());
   /**
        * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
        * 
        */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        AppContext appContext = AppContext.getAppContext();
        DemoUser user = appContext.getCurrentUser();
		PhotoServiceManager serviceManager = appContext.getPhotoServiceManager();
	    PhotoManager photoManager = appContext.getPhotoManager();
		
        String albumId = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID);
        
        if (request.getParameter("getfile") != null && !request.getParameter("getfile").isEmpty()) {
            /*
        	File file = new File(request.getServletPath()+"imgs/"+request.getParameter("getfile"));
            if (file.exists()) {
                int bytes = 0;
                ServletOutputStream op = response.getOutputStream();

                response.setContentType(getMimeType(file));
                response.setContentLength((int) file.length());
                response.setHeader( "Content-Disposition", "inline; filename=\"" + file.getName() + "\"" );

                byte[] bbuf = new byte[1024];
                DataInputStream in = new DataInputStream(new FileInputStream(file));

                while ((in != null) && ((bytes = in.read(bbuf)) != -1)) {
                    op.write(bbuf, 0, bytes);
                }

                in.close();
                op.flush();
                op.close();
            } */
        } else if (request.getParameter("delfile") != null && !request.getParameter("delfile").isEmpty()) {
            /*
        	File file = new File(request.getServletPath()+"imgs/"+ request.getParameter("delfile"));
            if (file.exists()) {
                file.delete(); // TODO:check and report success
            } */
        	long id = Long.parseLong(request.getParameter("delfile"));
	    	Photo photo = photoManager.deactivePhoto(user.getUserId(), id);
        } else if (request.getParameter("getthumb") != null && !request.getParameter("getthumb").isEmpty()) {
            /*
        	File file = new File(request.getServletPath()+"imgs/"+request.getParameter("getthumb"));
                if (file.exists()) {
                    System.out.println(file.getAbsolutePath());
                    String mimetype = getMimeType(file);
                    if (mimetype.endsWith("png") || mimetype.endsWith("jpeg")|| mimetype.endsWith("jpg") || mimetype.endsWith("gif")) {
                        //BufferedImage im = ImageIO.read(file);
                    	byte[] im = null;
                    	try {
                            // tmp.dat holds image, can be png, jpg
                    		im = Files.toByteArray( new File("tmp.dat"));
                          } catch (Exception e) {
                            e.printStackTrace();
                          }
                    
                    	if (im != null) {
                            //BufferedImage thumb = Scalr.resize(im, 75); 
                            ImagesService imagesService = ImagesServiceFactory.getImagesService();
                            Image oldImage = ImagesServiceFactory.makeImage(im);
                            Transform resize = ImagesServiceFactory.makeResize(75, 75);
                            Image newImage;

                            if (mimetype.endsWith("png")) {
                                //ImageIO.write(thumb, "PNG" , os);
                            	newImage = imagesService.applyTransform(resize, oldImage, ImagesService.OutputEncoding.PNG);
                                response.setContentType("image/png");
                            } else if (mimetype.endsWith("jpeg")) {
                                //ImageIO.write(thumb, "jpg" , os);
                            	newImage = imagesService.applyTransform(resize, oldImage, ImagesService.OutputEncoding.JPEG);
                                response.setContentType("image/jpeg");
                            } else if (mimetype.endsWith("jpg")) {
                                //ImageIO.write(thumb, "jpg" , os);
                            	newImage = imagesService.applyTransform(resize, oldImage, ImagesService.OutputEncoding.JPEG);
                                response.setContentType("image/jpeg");
                            } else {
                                //ImageIO.write(thumb, "GIF" , os);
                            	newImage = imagesService.applyTransform(resize, oldImage, ImagesService.OutputEncoding.valueOf("GIF"));
                                response.setContentType("image/gif");
                            }
                            byte[] newImageData = newImage.getImageData();
                            ByteArrayOutputStream os = new ByteArrayOutputStream();
                            os.write(newImageData);
                            ServletOutputStream srvos = response.getOutputStream();
                            response.setContentLength(os.size());
                            response.setHeader( "Content-Disposition", "inline; filename=\"" + file.getName() + "\"" );
                            os.writeTo(srvos);
                            srvos.flush();
                            srvos.close();
                        }
                    } 
            } */// TODO: check and report success
            String id = request.getParameter("getthumb");
            Long photoId = ServletUtils.validatePhotoId(id);
            if (photoId != null) {
	              Photo photo = AppContext.getAppContext().getPhotoManager().getPhoto(user.getUserId(), photoId);
	              BlobKey blobKey = photo.getBlobKey();
	              ImagesService imagesService = ImagesServiceFactory.getImagesService();
	
	              Image oldImage = ImagesServiceFactory.makeImageFromBlob(blobKey);
	              Transform resize = ImagesServiceFactory.makeResize(75, 75);
	
	              Image newImage = imagesService.applyTransform(resize, oldImage);
	
	              byte[] newImageData = newImage.getImageData();
                  ByteArrayOutputStream os = new ByteArrayOutputStream();
                  os.write(newImageData);
                  ServletOutputStream srvos = response.getOutputStream();
                  response.setContentType("image/png");
                  response.setContentLength(os.size());
                  response.setHeader( "Content-Disposition", "inline; filename=\"" + photo.getTitle() + "\"" );
                  os.writeTo(srvos);
                  srvos.flush();
                  srvos.close();
            }

        } else {
            PrintWriter writer = response.getWriter();
            writer.write("call POST with multipart form data");
        }
    	//response.sendRedirect(serviceManager.getViewUrl(null, user.getUserId(), null, albumId, "viewstream", null));

    }
    
    /**
        * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
        * 
        */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    	AppContext appContext = AppContext.getAppContext();
        DemoUser user = appContext.getCurrentUser();
        if (user == null) {
        	response.sendError(401, "You have to login to upload image.");
          return;
        }
        if (!ServletFileUpload.isMultipartContent(request)) {
            throw new IllegalArgumentException("Request is not multipart, please 'multipart/form-data' enctype for your form.");
        }

        PrintWriter writer = response.getWriter();
        response.setContentType("application/json");
        JSONArray json = new JSONArray();

        BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
        Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(request);
        Map<String, List<FileInfo>> infos = blobstoreService.getFileInfos(request);
        List<BlobKey> keys = blobs.get("files[]");
        List<FileInfo> fileinfos = infos.get("files[]");
        String id = null;
        String albumId = null;
        boolean succeeded = false;
        BlobKey blobKey = null;
        FileInfo info = null;
        
        if (keys != null && keys.size() > 0) {
            PhotoManager photoManager = appContext.getPhotoManager();
            albumId = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_ALBUM_ID);
            
        	try {
                Iterator<BlobKey> it = keys.iterator();
                Iterator<FileInfo> itInfo = fileinfos.iterator();

                while (it.hasNext()) { 
    	            blobKey = it.next();
    	            info = itInfo.next();
                	Photo photo = photoManager.newPhoto(user.getUserId());
     	            String title = request.getParameter("title");
    	            if (title != null) {
    	              photo.setTitle(title);
    	            }
    	            else
    	            	photo.setTitle(info.getFilename());
                
    	            String isPrivate = request.getParameter(ServletUtils.REQUEST_PARAM_NAME_PRIVATE);
    	            photo.setShared(isPrivate == null);
    	            
    	            photo.setAlbumId(albumId);
    	
    	            photo.setOwnerNickname(ServletUtils.getProtectedUserNickname(user.getNickname()));
    	
    	            photo.setBlobKey(blobKey);
    	
    	            photo.setUploadTime(System.currentTimeMillis());
    	
    	            photo = photoManager.upsertEntity(photo);
    	            id = photo.getId().toString();
 
                    System.out.println(info.getFilename() + "  " + String.valueOf(info.getSize()));

            	
                    JSONObject jsono = new JSONObject();
                   	jsono.put("name", info.getFilename());
                    jsono.put("size", String.valueOf(info.getSize())); 
                    //jsono.put("url", "UploadServlet?getfile=" + id +"&stream-id=" + albumId);
                    jsono.put("url", "/download?id=" + id +"&user=" + user.getUserId());
                    jsono.put("thumbnail_url", "UploadServlet?getthumb=" + id +"&stream-id=" + albumId);
                    /*
                    try {
                    	ImagesService imagesService = ImagesServiceFactory.getImagesService();
                    	ServingUrlOptions servingUrlOptions = ServingUrlOptions.Builder.withBlobKey(blobKey);
                    	imagesService.getServingUrl(servingUrlOptions);
                    	jsono.put("thumbnail_url", imagesService.getServingUrl(servingUrlOptions) +"=s75");
                    } catch (ImagesServiceFailureException e) {
                    	jsono.put("thumbnail_url", "/download?id=" + id +"&user=" + user.getUserId());
                    }
                    */
                    jsono.put("delete_url", "UploadServlet?delfile=" + id);
                    jsono.put("delete_type", "GET");
                    json.put(jsono);
                    System.out.println(json.toString());
                }
            //} catch (FileUploadException e) {
            //        throw new RuntimeException(e);
            } catch (Exception e) {
                    throw new RuntimeException(e);
            } finally {
                writer.write(json.toString());
                writer.close();
            }
            
            succeeded = true;
        }
        if (succeeded) {
        	//response.sendRedirect(appContext.getPhotoServiceManager().getViewUrl(
        		//	request.getParameter(ServletUtils.REQUEST_PARAM_NAME_TARGET_URL), user.getUserId(), id, albumId, "viewstream",null));
        } else {
        	  response.sendError(400, "Request cannot be handled.");
        }  
    }

    private String getMimeType(File file) {
        String mimetype = "";
        if (file.exists()) {
            if (getSuffix(file.getName()).equalsIgnoreCase("png")) {
                mimetype = "image/png";
            }else if(getSuffix(file.getName()).equalsIgnoreCase("jpg")){
                mimetype = "image/jpg";
            }else if(getSuffix(file.getName()).equalsIgnoreCase("jpeg")){
                mimetype = "image/jpeg";
            }else if(getSuffix(file.getName()).equalsIgnoreCase("gif")){
                mimetype = "image/gif";
            }else {
                javax.activation.MimetypesFileTypeMap mtMap = new javax.activation.MimetypesFileTypeMap();
                mimetype  = mtMap.getContentType(file);
            }
        }
        return mimetype;
    }

    private String getSuffix(String filename) {
        String suffix = "";
        int pos = filename.lastIndexOf('.');
        if (pos > 0 && pos < filename.length() - 1) {
            suffix = filename.substring(pos + 1);
        }
        return suffix;
    }
}