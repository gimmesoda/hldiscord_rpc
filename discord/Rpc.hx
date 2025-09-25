package discord;

import discord._internal.*;

@:access(String.fromUTF8)
@:access(String.toUtf8)
@:noPrivateAccess class Rpc {
	public static var handlers:Null<Event.Handlers>;

	public static final callbacksDaemon:CallbacksDaemon = new CallbacksDaemon();

	public static function initialize(applicationId:String, ?handlers:Event.Handlers, ?steamId:String) {
		Rpc.handlers = handlers;

		NativeRpc.initialize(applicationId.toUtf8(), ready, disconnected, errored, joinGame, spectateGame, joinRequest, steamId?.toUtf8());
	}

	public static function runCallbacks() {
		NativeRpc.runCallbacks();
	}

	public static function release() {
		NativeRpc.shutdown();
	}

	public static function updateActivity(activity:Activity) {
		final v:Activity = activity;
		if (v == null) NativeRpc.clearPresence();
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

			NativeRpc.updatePresence(v.type, state, details, v.timestamps.start, v.timestamps.end, largeImageKey, largeImageText, smallImageKey,
				smallImageText, partyId, v.party?.size?.current, v.party?.size?.max, v.party?.privacy, button1_label, button1_url, button2_label, button2_url,
				matchSecret, joinSecret, spectateSecret, v.instance);
		}
	}

	public static function respond(userId:String, reply:Activity.JoinRequestReply) {
		NativeRpc.respond(userId.toUtf8(), reply);
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
private class NativeRpc {
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
