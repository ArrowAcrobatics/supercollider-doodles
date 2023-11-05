// hello world
s.boot; // ctrl + b
s.plotTree;

MIDIClient.init;
MIDIIn.connectAll;

(
SynthDef.new(
	\mysynth,{
		arg freq=440, amp=0.3, gate=1; // t_ for trigger gate, don't use for sustained sounds.
		var sig, env;
		env = EnvGen.kr(Env.new(
			[0,1,0.2,0],
			[0.5,  1,2],
			[3,-3,0]),
			gate,
			doneAction:2
		);
		sig = Pulse.ar(LFPulse.kr(8).range(freq,freq+Line.kr(300,0,3)));
			Out.ar(0,sig*env*amp);
		}
	).add;
)

~notes = Array.newClear(128);

(
MIDIdef.noteOn(\kb_on, {
	arg vel, num, chan, src;
	["note on:",vel, num].postln;
	~notes[num] = Synth.new(\mysynth,
			[\freq, num.midicps, \amp,vel.linexp(1,127,0.01,0.3)]);

//	~notes[num].set(\gate, 1);
});
)

(
MIDIdef.noteOff(\kb_off, {
	arg vel, num, chan, src;
	["note off:",vel, num].postln;
	~notes[num].set(\gate, 0);
	~notes[num] = nil; // server side should does not garbage dispose if we loose the refs
});
)