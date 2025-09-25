package discord;

enum abstract PremiumType(Int) from Int to Int {
	var None:PremiumType;
	var NitroClassic:PremiumType;
	var Nitro:PremiumType;
	var NitroBasic:PremiumType;
}

@:noPrivateAccess final class User {
	public final userId:String;
	public final username:String;
	public final globalName:String;
	public final discriminator:String;
	public final avatar:String;
	public final premiumType:PremiumType;
	public final bot:Bool;

	@:allow(discord)
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
