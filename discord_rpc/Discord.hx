package discord_rpc;

import haxe.ds.Vector;
import sys.thread.Thread;
import haxe.Int64;

enum abstract PremiumType(Int) from Int to Int {
	var None:PremiumType;
	var NitroClassic:PremiumType;
	var Nitro:PremiumType;
	var NitroBasic:PremiumType;
}

enum abstract ActivityPartyPrivacy(Int) from Int to Int {
	var Private:ActivityPartyPrivacy;
	var Public:ActivityPartyPrivacy;
}

enum abstract ActivityType(Int) from Int to Int {
	var Playing:ActivityType = 0;
	var Listening:ActivityType = 2;
	var Watching:ActivityType = 3;
	var Competing:ActivityType = 5;
}

enum abstract ActivityJoinRequestReply(Int) from Int to Int {
	var No:ActivityJoinRequestReply;
	var Yes:ActivityJoinRequestReply;
	var Ignore:ActivityJoinRequestReply;
}

final class ActivityTimestamps {
	public var start:Int64;
	public var end:Int64;

	public function new(start:Int64 = 0, end:Int64 = 0) {
		set(start, end);
	}

	public inline function set(start:Int64, end:Int64):ActivityTimestamps {
		this.start = start;
		this.end = end;
		return this;
	}

	public inline function reset():ActivityTimestamps {
		return set(0, 0);
	}
}

final class ActivityAssets {
	public var largeImage:Null<String>;
	public var largeText:Null<String>;

	public var smallImage:Null<String>;
	public var smallText:Null<String>;

	public function new() {
	}

	public inline function setLarge(image:String, text:String):ActivityAssets {
		largeImage = image;
		largeText = text;
		return this;
	}

	public inline function setSmall(image:String, text:String):ActivityAssets {
		smallImage = image;
		smallText = text;
		return this;
	}

	public inline function resetLarge():ActivityAssets {
		return setLarge(null, null);
	}

	public inline function resetSmall():ActivityAssets {
		return setSmall(null, null);
	}

	public inline function reset():ActivityAssets {
		return resetLarge().resetSmall();
	}
}

final class ActivityPartySize {
	public var current:Int = 0;
	public var max:Int = 0;

	public function new(current:Int = 0, max:Int = 0) {
		set(current, max);
	}

	public inline function set(current:Int, max:Int):ActivityPartySize {
		this.current = current;
		this.max = max;
		return this;
	}

	public inline function reset() {
		return set(0, 0);
	}
}

@:nullSafety final class ActivityParty {
	public var id:String;
	public var size:ActivityPartySize;
	public var privacy:ActivityPartyPrivacy = Public;

	public function new(id:String) {
		this.id = id;
		size = new ActivityPartySize();
	}
}

@:nullSafety final class ActivityButton {
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

final class ActivitySecrets {
	public var match:Null<String>;
	public var join:Null<String>;
	public var spectate:Null<String>;

	public function new() {
	}
}

final class Activity {
	public var type:ActivityType;

	public var state:String;
	public var details:String;

	public var timestamps:ActivityTimestamps;

	public var assets:ActivityAssets;

	public var party:Null<ActivityParty>;

	public var buttons(default, set):Null<Vector<ActivityButton>>;

	public var secrets:ActivitySecrets;

	public var instance:Bool;

	public function new() {
		timestamps = new ActivityTimestamps();
		assets = new ActivityAssets();
		secrets = new ActivitySecrets();
	}

	@:noCompletion private inline function set_buttons(v:Null<Vector<ActivityButton>>):Null<Vector<ActivityButton>> {
		if (v != null && v.length > 2) throw 'Too many buttons(${v.length} / 2)';
		return buttons = v;
	}
}

@:noPrivateAccess final class User {
	public final userId:String;
	public final username:String;
	public final globalName:String;
	public final discriminator:String;
	public final avatar:String;
	public final premiumType:PremiumType;
	public final bot:Bool;

	@:allow(discord_rpc)
	private function new(userId:String, username:String, globalName:String, discriminator:String, avatar:String, premiumType:Int, bot:Bool) {
		this.userId = userId;
		this.username = username;
		this.globalName = globalName;
		this.discriminator = discriminator;
		this.avatar = avatar;
		this.premiumType = premiumType;
		this.bot = bot;
	}
}

@:noPrivateAccess final class EventHandlers {
	public var ready:(request:User) -> Void;
	public var disconnected:(errorCode:Int, message:String) -> Void;
	public var errored:(errorCode:Int, message:String) -> Void;
	public var joinGame:(joinSecret:String) -> Void;
	public var spectateGame:(spectateSecret:String) -> Void;
	public var joinRequest:(request:User) -> Void;

	public function new() {
	}
}

@:access(String.fromUTF8)
@:access(String.toUtf8)
@:noPrivateAccess class Discord {
	public static var handlers:Null<EventHandlers>;

	private static inline var CALLBACKS_DAEMON_STOP_WORD:String = 'stop';
	private static var callbacksDaemon:Null<Thread>;

	public static function initialize(applicationId:String, ?handlers:EventHandlers, ?steamId:String) {
		Discord.handlers = handlers;

		DiscordRpc.initialize(applicationId.toUtf8(), ready, disconnected, errored, joinGame, spectateGame, joinRequest, steamId?.toUtf8());
	}

	public static function runCallbacks() {
		DiscordRpc.runCallbacks();
	}

	public static function createCallbacksDaemon(cooldown:Float = 0.4) {
		destroyCallbacksDaemon();

		callbacksDaemon = Thread.create(() -> {
			while (true) {
				if (Thread.readMessage(false) == CALLBACKS_DAEMON_STOP_WORD) break;

				runCallbacks();
				Sys.sleep(cooldown);
			}
		});
	}

	public static function destroyCallbacksDaemon() {
		callbacksDaemon?.sendMessage(CALLBACKS_DAEMON_STOP_WORD);
		callbacksDaemon = null;
	}

	public static function shutdown() {
		DiscordRpc.shutdown();
	}

	public static function updateActivity(activity:Activity) {
		final v:Activity = activity;
		if (v == null) DiscordRpc.clearPresence();
		else {
			final state:hl.Bytes = v.state?.toUtf8();
			final details:hl.Bytes = v.details?.toUtf8();
			final largeImageKey:hl.Bytes = v.assets?.largeImage?.toUtf8();
			final largeImageText:hl.Bytes = v.assets?.largeText?.toUtf8();
			final smallImageKey:hl.Bytes = v.assets?.smallImage?.toUtf8();
			final smallImageText:hl.Bytes = v.assets?.smallText?.toUtf8();
			final partyId:hl.Bytes = v.party?.id?.toUtf8();
			final button1_label:hl.Bytes = v.buttons == null ? null : v.buttons[0]?.label?.toUtf8();
			final button1_url:hl.Bytes = v.buttons == null ? null : v.buttons[0]?.url?.toUtf8();
			final button2_label:hl.Bytes = v.buttons == null ? null : v.buttons[1]?.label?.toUtf8();
			final button2_url:hl.Bytes = v.buttons == null ? null : v.buttons[1]?.url?.toUtf8();
			final matchSecret:hl.Bytes = v.secrets?.match?.toUtf8();
			final joinSecret:hl.Bytes = v.secrets?.join?.toUtf8();
			final spectateSecret:hl.Bytes = v.secrets?.spectate?.toUtf8();

			DiscordRpc.updatePresence(v.type, state, details, v.timestamps.start, v.timestamps.end, largeImageKey, largeImageText, smallImageKey,
				smallImageText, partyId, v.party?.size?.current, v.party?.size?.max, v.party?.privacy, button1_label, button1_url, button2_label, button2_url,
				matchSecret, joinSecret, spectateSecret, v.instance);
		}
	}

	public static function respond(userId:String, reply:ActivityJoinRequestReply) {
		DiscordRpc.respond(userId.toUtf8(), reply);
	}

	// =======================
	// Private event wrappers
	// =======================

	private static function ready(userId:hl.Bytes, username:hl.Bytes, globalName:hl.Bytes, discriminator:hl.Bytes, avatar:hl.Bytes, premiumType:Int, bot:Bool) {
		if (handlers?.ready == null) return;

		final request = new User(String.fromUTF8(userId), String.fromUTF8(username), String.fromUTF8(globalName), String.fromUTF8(discriminator),
			String.fromUTF8(avatar), premiumType, bot);

		handlers.ready(request);
	}

	private static function disconnected(errorCode:Int, message:hl.Bytes) {
		if (handlers?.disconnected == null) return;

		handlers.disconnected(errorCode, String.fromUTF8(message));
	}

	private static function errored(errorCode:Int, message:hl.Bytes) {
		if (handlers?.errored == null) return;

		handlers.errored(errorCode, String.fromUTF8(message));
	}

	private static function joinGame(joinSecret:hl.Bytes) {
		if (handlers?.joinGame == null) return;

		handlers.joinGame(String.fromUTF8(joinSecret));
	}

	private static function spectateGame(spectateSecret:hl.Bytes) {
		if (handlers?.spectateGame == null) return;

		handlers.spectateGame(String.fromUTF8(spectateSecret));
	}

	private static function joinRequest(userId:hl.Bytes, username:hl.Bytes, globalName:hl.Bytes, discriminator:hl.Bytes, avatar:hl.Bytes, premiumType:Int,
			bot:Bool) {
		if (handlers?.joinRequest == null) return;

		final request = new User(String.fromUTF8(userId), String.fromUTF8(username), String.fromUTF8(globalName), String.fromUTF8(discriminator),
			String.fromUTF8(avatar), premiumType, bot);

		handlers.joinRequest(request);
	}
}

private typedef RequestHandler = (userId:hl.Bytes, username:hl.Bytes, globalName:hl.Bytes, discriminator:hl.Bytes, avatar:hl.Bytes, premiumType:Int,
	bot:Bool) -> Void;

private typedef ErrorHandler = (errorCode:Int, message:hl.Bytes) -> Void;
private typedef SecretHandler = (secret:hl.Bytes) -> Void;

@:hlNative('discord_rpc')
private class DiscordRpc {
	public static function initialize(applicationId:hl.Bytes, ready:RequestHandler, disconnected:ErrorHandler, errored:ErrorHandler, joinGame:SecretHandler,
		spectateGame:SecretHandler, joinRequest:RequestHandler, steamId:hl.Bytes,) {
	}

	public static function registerCommand(applicationid:hl.Bytes, command:hl.Bytes) {
	}

	public static function registerSteamGame(applicationId:hl.Bytes, steamId:hl.Bytes) {
	}

	public static function runCallbacks() {
	}

	public static function shutdown() {
	}

	public static function updatePresence(type:Int, state:hl.Bytes, details:hl.Bytes, startTimestamp:hl.I64, endTimestamp:hl.I64, largeImageKey:hl.Bytes,
		largeImageText:hl.Bytes, smallImageKey:hl.Bytes, smallImageText:hl.Bytes, partyId:hl.Bytes, partySize:Int, partyMax:Int, partyPrivacy:Int,
		button1_label:hl.Bytes, button1_url:hl.Bytes, button2_label:hl.Bytes, button2_url:hl.Bytes, matchSecret:hl.Bytes, joinSecret:hl.Bytes,
		spectateSecret:hl.Bytes, instance:Bool) {
	}

	public static function clearPresence() {
	}

	public static function respond(userId:hl.Bytes, reply:Int) {
	}
}
