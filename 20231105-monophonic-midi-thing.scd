s.boot; // ctrl + b
s.plotTree;

MIDIClient.init;
MIDIIn.connectAll;

(
SynthDef.new(
	\mysynth,{
		arg freq=440, amp=0.3, t_gate=0; // t_ for trigger gate, don't use for sustained sounds.
		var sig, env;
		env = EnvGen.kr(Env.new(
			[0,1,0.2,0],
			[0.5,  1,2],
			[3,-3,0]),
			t_gate
		);
		sig = Pulse.ar(LFPulse.kr(8).range(freq,freq+300));
		Out.ar(0,sig*env*amp);
	}
).add;
)

~mysynth0 = Synth.new(\mysynth);

(
MIDIdef.noteOn(\kb, {
	arg vel, num, chan, src;
	["note received:",vel, num].postln;
	~mysynth0.set(\freq, num.midicps, \amp, vel.linexp(1,127,0.01,0.3), \t_gate, 1);
});
)

