package com.google.cloud.demo;

import java.util.List;

import com.googlecode.objectify.ObjectifyService;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.google.common.base.Joiner;

@Entity
public class Hints implements Comparable<Hints> {

	static {
		 ObjectifyService.register(Hints.class);
	}
	// id is set by the datastore for us
	@Id
	public Long id;
	public String value;
	public String label;
  
	// TODO: figure out why this is needed
	@SuppressWarnings("unused")
	private Hints() {
	}
	
	@Override
	public String toString() {
		Joiner joiner = Joiner.on(":");
		return joiner.join(id.toString(), value, label);
 	}

	public Hints(String label, String value) {
		this.value = value;
		if(label == null)
			this.label = value;
		else
			this.label = label;
	}

	public Hints(Long id, String label, String value) {
		this.id = id;
		this.value = value;
		if(label == null)
			this.label = value;
		else
			this.label = label;
	}

	@Override
	public int compareTo(Hints other) {
		return value.compareTo(other.value);
	}
	
	public boolean isAlreadyInList(Hints other) {
		List<Hints> hints = OfyService.ofy().load().type(Hints.class).list();
		for(Hints hint : hints) {
			if(hint.compareTo(other) == 0)
				return true;
		}
			
		return false;
	}
}
