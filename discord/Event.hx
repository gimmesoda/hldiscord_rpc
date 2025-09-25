package discord;

typedef Request = (request:User) -> Void;
typedef Error = (errorCode:Int, message:String) -> Void;
typedef Secret = (secret:String) -> Void;

final class Handlers {
	public var ready:Request;
	public var disconnected:Error;
	public var errored:Error;
	public var joinGame:Secret;
	public var spectateGame:Secret;
	public var joinRequest:Request;

	public function new() {
	}
}
