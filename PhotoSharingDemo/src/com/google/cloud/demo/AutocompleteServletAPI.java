package com.google.cloud.demo;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.logging.Logger;

import javax.servlet.http.*;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.util.logging.Logger;

import static com.googlecode.objectify.ObjectifyService.ofy;

@SuppressWarnings("serial")
public class AutocompleteServletAPI extends HttpServlet {
	
	private static final Logger log = Logger.getLogger(AutocompleteServletAPI.class.getName());
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		
		log.warning("Entering AllStreamsServletAPI");
		List<Hints> hints = OfyService.ofy().load().type(Hints.class).list();
        String search_text = req.getParameter(ServletUtils.REQUEST_PARAM_NAME_SEARCH_HINT);
		ArrayList<Hints> sorted_hints = new ArrayList<Hints>();
		int count = 0;
        
        if (search_text != null) {   		  
			for (Hints hint : hints) {
				if ((hint.value).indexOf(search_text) != -1) {
					Hints h = new Hints(hint.id, hint.value.concat(" ").concat(hint.label), hint.value);
					sorted_hints.add(h);
					count++;
				}
				else if ((hint.label!=null)&& (hint.label).indexOf(search_text) != -1) {
					Hints h = new Hints(hint.id, hint.value.concat(" ").concat(hint.label), hint.value);
						sorted_hints.add(h); 
						count++;
				}
				if (count >= 20)
					break;
			}
		}
		Collections.sort(sorted_hints);

        
		Gson gson = new Gson();
		String json = gson.toJson(sorted_hints);
		resp.setContentType("application/json");
		resp.getWriter().print(json);
		
		// for debugging
		Type t = new TypeToken<List<Hints>>(){}.getType();
		List<Hints> fromJson = (List<Hints>) gson.fromJson(json, t);
		for (Hints s : fromJson ) {
			System.out.println(s);
		}
	}
}