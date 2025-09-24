package test;

import discord_rpc.Discord;

function main() {
	final handlers = new DiscordEventHandlers();
	handlers.ready = (request:DiscordUser) -> {
		trace('Connected to ${request.username}');
	}

	Discord.initialize('1417413098482172044', handlers);
	Discord.createCallbacksDaemon();

	final activity:DiscordActivity = new DiscordActivity();
	activity.state = 'passed!';
	activity.timestamps.start = haxe.Int64.fromFloat(Date.now().getTime()) - haxe.Int64.fromFloat(Date.now().getTime());
	Discord.updateActivity(activity);

	while (true) {
	}
}
