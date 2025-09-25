package discord;

import haxe.ds.Vector;
import haxe.Int64;

enum abstract Type(Int) from Int to Int {
	var Playing:Type = 0;
	var Listening:Type = 2;
	var Watching:Type = 3;
	var Competing:Type = 5;
}

final class Timestamps {
	public var start:Int64;
	public var end:Int64;

	public function new(start:Int64 = 0, end:Int64 = 0) {
		set(start, end);
	}

	public inline function set(start:Int64, end:Int64):Timestamps {
		this.start = start;
		this.end = end;
		return this;
	}

	public inline function reset():Timestamps {
		return set(0, 0);
	}
}

final class Assets {
	public var largeImage:Null<String>;
	public var largeText:Null<String>;

	public var smallImage:Null<String>;
	public var smallText:Null<String>;

	public function new() {
	}

	public inline function setLarge(image:String, text:String):Assets {
		largeImage = image;
		largeText = text;
		return this;
	}

	public inline function setSmall(image:String, text:String):Assets {
		smallImage = image;
		smallText = text;
		return this;
	}

	public inline function resetLarge():Assets {
		return setLarge(null, null);
	}

	public inline function resetSmall():Assets {
		return setSmall(null, null);
	}

	public inline function reset():Assets {
		return resetLarge().resetSmall();
	}
}

final class PartySize {
	public var current:Int = 0;
	public var max:Int = 0;

	public function new(current:Int = 0, max:Int = 0) {
		set(current, max);
	}

	public inline function set(current:Int, max:Int):PartySize {
		this.current = current;
		this.max = max;
		return this;
	}

	public inline function reset() {
		return set(0, 0);
	}
}

enum abstract PartyPrivacy(Int) from Int to Int {
	var Private:PartyPrivacy;
	var Public:PartyPrivacy;
}

@:nullSafety final class Party {
	public var id:String;
	public var size:PartySize;
	public var privacy:PartyPrivacy = Public;

	public function new(id:String) {
		this.id = id;
		size = new PartySize();
	}
}

@:nullSafety final class Button {
	public var label:String;
	public var url:String;

	public function new(label:String, url:String) {
		set(label, url);
	}

	public inline function set(label:String, url:String) {
		this.label = label;
		this.url = url;
	}
}

final class Secrets {
	public var match:Null<String>;
	public var join:Null<String>;
	public var spectate:Null<String>;

	public function new() {
	}
}

final class Activity {
	public var type:Type;

	public var state:String;
	public var details:String;

	public var timestamps:Timestamps;

	public var assets:Assets;

	public var party:Null<Party>;

	public var buttons(default, set):Null<Vector<Button>>;

	public var secrets:Secrets;

	public var instance:Bool;

	public function new() {
		timestamps = new Timestamps();
		assets = new Assets();
		secrets = new Secrets();
	}

	@:noCompletion private inline function set_buttons(v:Null<Vector<Button>>):Null<Vector<Button>> {
		if (v != null && v.length > 2) throw 'Too many buttons(${v.length} / 2)';
		return buttons = v;
	}
}

enum abstract JoinRequestReply(Int) from Int to Int {
	var No:JoinRequestReply;
	var Yes:JoinRequestReply;
	var Ignore:JoinRequestReply;
}
