thisProcess.openUDPPort(44718); // attempt to open a port
thisProcess.openPorts; // list all open ports

o = OSCFunc(
	{ arg msg, time, addr, recvPort;
	[msg, time, addr, recvPort].postln;
}, '/unity/rotation');

o.free;