package sample;

import haxe.ds.Vector;
import discord.*;

function main() {
	final handlers = new Event.Handlers();
	handlers.ready = (request:User) -> {
		final userString:String = request.username + (request.discriminator == '0' ? '' : '#${request.discriminator}');
		trace('Connected to $userString');
	}

	Rpc.initialize('1417413098482172044', handlers);
	Rpc.callbacksDaemon.create();

	final activity:Activity = new Activity();
	activity.state = 'passed!';

	final buttons:Array<Activity.Button> = [new Activity.Button('GitHub repo', 'https://github.com/gimmesoda/hldiscord_rpc')];
	activity.buttons = Vector.fromArrayCopy(buttons);

	Rpc.updateActivity(activity);

	Sys.getChar(false);
	Rpc.release();
}
