# What is this?

RBXRemote is just a quick, open source script by [Rerumu](https://www.roblox.com/users/70540486/profile) to work a bit better with FilteringEnabled and having fun while making it.
Functions are documented further ahead.
For this to work it must be a ModuleScript and required in ReplicatedStorage; only one is needed.

# Documentation

This documentation is written in a C++ like style.

## Server Sided

```Cpp
variant Get(player Player, variant ...);
// Calls upon Player's Hook callback, passes ... and yields until it finishes or returns.

void Send(player Player, variant ...);
// Fires all connected events in the Player with ... passed as arguments.

void SendAll(variant ...);
// Fires all connected events of all clients while passing ... as arguments.

RBXScriptSignal Connect(lua_function Function);
// Connects a function to the server to be fired by Send client-side.

variant Hook(player Player, variant ...) = 0;
// A callback that can be set to handle a player Get and return.
```

## Client Sided

```Cpp
variant Fetch(player OtherPlayer, bool Returns, variant ...);
// Invokes Cross callback in Player with the the firing client as the first argument followed by ... and yields until a response if Returns.

variant Get(variant ...);
// Invokes Hook callback on the server and yields until it finishes or returns.

void Send(variant ...);
// Fires all connected events on the server with ... as the arguments.

RBXScriptSignal Connect(lua_function);
// Connects a function to the client to be fired via Send server-side.

variant Hook(variant ...) = 0;
// A callback that can be set to handle the server Get and return.

variant Cross(player OtherPlayer, variant ...) = 0;
// A callback that can be set to handle Fetch requests from other clients.
```
