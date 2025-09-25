package discord._internal;

import sys.thread.Thread;

final class CallbacksDaemon {
	private static inline var STOP_MESSAGE:String = 'Stop';

	public var period:Float = 0.4;

	private var thread:Thread;

	@:allow(discord)
	private function new() {
	}

	public function create(period:Float = 0.4) {
		this.period = period;
		thread = Thread.create(threadJob);
	}

	public function release() {
		thread?.sendMessage(STOP_MESSAGE);
		thread = null;
	}

	private function threadJob() {
		while (true) {
			if (Thread.readMessage(false) == STOP_MESSAGE) break;

			Rpc.runCallbacks();
			Sys.sleep(period);
		}
	}
}
