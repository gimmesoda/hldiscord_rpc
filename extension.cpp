#define HL_NAME(n) discord_rpc_##n
#include <hl.h>

#include <discord_rpc.hpp>

DiscordEventHandlers* handlersWrapper;
DiscordRichPresence* presenceWrapper;

vclosure* readyHandler;
vclosure* disconnectedHandler;
vclosure* erroredHandler;
vclosure* joinGameHandler;
vclosure* spectateGameHandler;
vclosure* joinRequestHandler;

void initHandlersWrapper() {
	handlersWrapper = new DiscordEventHandlers();

	handlersWrapper->ready = [](const DiscordUser* request) {
		vdynamic args[7];
		vdynamic* vargs[7] = {&args[0], &args[1], &args[2], &args[3], &args[4], &args[5], &args[6]};

		args[0].t = &hlt_bytes;
		args[0].v.bytes = (vbyte*)(request->userId);
		args[1].t = &hlt_bytes;
		args[1].v.bytes = (vbyte*)(request->username);
		args[2].t = &hlt_bytes;
		args[2].v.bytes = (vbyte*)(request->globalName);
		args[3].t = &hlt_bytes;
		args[3].v.bytes = (vbyte*)(request->discriminator);
		args[4].t = &hlt_bytes;
		args[4].v.bytes = (vbyte*)(request->avatar);
		args[5].t = &hlt_i32;
		args[5].v.i = (int)(request->premiumType);
		args[6].t = &hlt_bool;
		args[6].v.i = request->bot;

		hl_dyn_call(readyHandler, vargs, 7);
	};

	handlersWrapper->disconnected = [](int errorCode, const char* message) {
		vdynamic args[2];
		vdynamic* vargs[2] = {&args[0], &args[1]};

		args[0].t = &hlt_i32;
		args[0].v.i = errorCode;
		args[1].t = &hlt_bytes;
		args[1].v.b = (vbyte*)message;

		hl_dyn_call(disconnectedHandler, vargs, 2);
	};

	handlersWrapper->errored = [](int errorCode, const char* message) {
		vdynamic args[2];
		vdynamic* vargs[2] = {&args[0], &args[1]};

		args[0].t = &hlt_i32;
		args[0].v.i = errorCode;
		args[1].t = &hlt_bytes;
		args[1].v.b = (vbyte*)message;

		hl_dyn_call(erroredHandler, vargs, 2);
	};

	handlersWrapper->joinGame = [](const char* joinSecret) {
		vdynamic args[1];
		vdynamic* vargs[1] = {&args[0]};

		args[0].t = &hlt_bytes;
		args[0].v.b = (vbyte*)joinSecret;

		hl_dyn_call(joinGameHandler, vargs, 1);
	};

	handlersWrapper->spectateGame = [](const char* spectateSecret) {
		vdynamic args[1];
		vdynamic* vargs[1] = {&args[0]};

		args[0].t = &hlt_bytes;
		args[0].v.b = (vbyte*)spectateSecret;

		hl_dyn_call(spectateGameHandler, vargs, 1);
	};

	handlersWrapper->joinRequest = [](const DiscordUser* request) {
		vdynamic args[7];
		vdynamic* vargs[7] = {&args[0], &args[1], &args[2], &args[3], &args[4], &args[5], &args[6]};

		args[0].t = &hlt_bytes;
		args[0].v.bytes = (vbyte*)(request->userId);
		args[1].t = &hlt_bytes;
		args[1].v.bytes = (vbyte*)(request->username);
		args[2].t = &hlt_bytes;
		args[2].v.bytes = (vbyte*)(request->globalName);
		args[3].t = &hlt_bytes;
		args[3].v.bytes = (vbyte*)(request->discriminator);
		args[4].t = &hlt_bytes;
		args[4].v.bytes = (vbyte*)(request->avatar);
		args[5].t = &hlt_i32;
		args[5].v.i = (int)(request->premiumType);
		args[6].t = &hlt_bool;
		args[6].v.i = request->bot;

		hl_dyn_call(joinRequestHandler, vargs, 7);
	};
}

HL_PRIM void HL_NAME(initialize)(vbyte* applicationId, vclosure* ready, vclosure* disconnected, vclosure* errored, vclosure* joinGame,
		vclosure* spectateGame, vclosure* joinRequest, vbyte* steamId) {
	readyHandler = ready;
	disconnectedHandler = disconnected;
	erroredHandler = errored;
	joinGameHandler = joinGame;
	spectateGameHandler = spectateGame;
	joinRequestHandler = joinRequest;

	if (!handlersWrapper) initHandlersWrapper();

	if (!steamId) Discord_Initialize((const char*)applicationId, handlersWrapper, false, nullptr);
	else Discord_Initialize((const char*)applicationId, handlersWrapper, true, (const char*)steamId);
}

HL_PRIM void HL_NAME(register_command)(vbyte* applicationId, vbyte* command) {
	Discord_Register((const char*)applicationId, (const char*)command);
}

HL_PRIM void HL_NAME(register_steam_game)(vbyte* applicationId, vbyte* steamId) {
	Discord_RegisterSteamGame((const char*)applicationId, (const char*)steamId);
}

HL_PRIM void HL_NAME(run_callbacks)() {
	Discord_RunCallbacks();
}

HL_PRIM void HL_NAME(shutdown)() {
	Discord_Shutdown();
}

HL_PRIM void HL_NAME(update_presence)(int type, vbyte* state, vbyte* details, int64_t startTimestamp, int64_t endTimestamp, vbyte* largeImageKey,
		vbyte* largeImageText, vbyte* smallImageKey, vbyte* smallImageText, vbyte* partyId, int partySize, int partyMax, int partyPrivacy,
		vbyte* button1_label, vbyte* button1_url, vbyte* button2_label, vbyte* button2_url, vbyte* matchSecret, vbyte* joinSecret,
		vbyte* spectateSecret, bool instance) {
	if (!presenceWrapper) presenceWrapper = new DiscordRichPresence();

	presenceWrapper->type = (DiscordActivityType)type;

	presenceWrapper->state = (const char*)state;
	presenceWrapper->details = (const char*)details;

	presenceWrapper->startTimestamp = startTimestamp;
	presenceWrapper->endTimestamp = endTimestamp;

	presenceWrapper->largeImageKey = (const char*)largeImageKey;
	presenceWrapper->largeImageText = (const char*)largeImageText;

	presenceWrapper->smallImageKey = (const char*)smallImageKey;
	presenceWrapper->smallImageText = (const char*)smallImageText;

	presenceWrapper->partyId = (const char*)partyId;
	presenceWrapper->partySize = partySize;
	presenceWrapper->partyMax = partyMax;
	presenceWrapper->partyPrivacy = (DiscordActivityPartyPrivacy)partyPrivacy;

	presenceWrapper->buttons[0] = {(const char*)button1_label, (const char*)button1_url};
	presenceWrapper->buttons[1] = {(const char*)button2_label, (const char*)button2_url};

	presenceWrapper->matchSecret = (const char*)matchSecret;
	presenceWrapper->joinSecret = (const char*)joinSecret;
	presenceWrapper->spectateSecret = (const char*)spectateSecret;

	presenceWrapper->instance = instance;

	Discord_UpdatePresence(presenceWrapper);
}

HL_PRIM void HL_NAME(clear_presence)() {
	Discord_ClearPresence();
}

HL_PRIM void HL_NAME(respond)(vbyte* userId, int reply) {
	Discord_Respond((const char*)userId, (DiscordActivityJoinRequestReply)reply);
}

#define _REQUEST_HANDLER _FUN(_VOID, _BYTES _BYTES _BYTES _BYTES _BYTES _I32 _BOOL)
#define _ERROR_HANDLER _FUN(_VOID, _I32 _BYTES)
#define _SECRET_HANDLER _FUN(_VOID, _BYTES)

DEFINE_PRIM(_VOID, initialize, _BYTES _REQUEST_HANDLER _ERROR_HANDLER _ERROR_HANDLER _SECRET_HANDLER
	_SECRET_HANDLER _REQUEST_HANDLER _BYTES);

DEFINE_PRIM(_VOID, register_command, _BYTES _BYTES);

DEFINE_PRIM(_VOID, register_steam_game, _BYTES _BYTES);

DEFINE_PRIM(_VOID, run_callbacks, _NO_ARG);

DEFINE_PRIM(_VOID, shutdown, _NO_ARG);

DEFINE_PRIM(_VOID, update_presence, _I32 _BYTES _BYTES _I64 _I64 _BYTES _BYTES _BYTES _BYTES _BYTES _I32 _I32 _I32 _BYTES _BYTES _BYTES _BYTES _BYTES _BYTES _BYTES _BOOL);

DEFINE_PRIM(_VOID, clear_presence, _NO_ARG);

DEFINE_PRIM(_VOID, respond, _BYTES _I32);
