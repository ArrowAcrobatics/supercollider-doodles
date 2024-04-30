// hello world
// s.boot; // ctrl + b
s.plotTree;
s.queryAllNodes;
// s.sendMsg("n_free",2809); // hackzors: https://doc.sccode.org/Guides/NodeMessaging.html

MIDIClient.init;
MIDIIn.connectAll;

// global variables
(
~notes = Array.newClear(128);
~notes1 = Array.newClear(128);
~ccv = Array.fill(8, {0;});
~ccs = 8.collect({arg i; "cc_".catArgs(i).asSymbol});
)

~notes1.do({arg i, item; i.free; item.free;});

(
SynthDef.new(
	\mysynth,{
		arg freq=440, amp=0.3, gate=1, ccv0=0; // t_ for trigger gate, don't use for sustained sounds.
		var sig, env;
		env = EnvGen.kr(Env.new(
			[0,0,1,0],
			[0.5,0.5,  1],
			[0,3,-3]),
			gate
			,doneAction:2
		);

		sig = Pulse.ar(LFPulse.kr(8).range(freq,freq+XLine.kr(ccv0*300+0.01,0.01,3)-0.01));
			Out.ar(0,sig*env*amp);
		}
	).add;
)

(
SynthDef.new(
	\directAttack,{
		arg freq=440, amp=0.3, gate=1, ccv0=0; // t_ for trigger gate, don't use for sustained sounds.
		var sig, env;
		env = EnvGen.kr(
			Env.adsr(),
			gate,
			doneAction:2
		);

		sig = Pulse.ar(freq);
			Out.ar(0,sig*env*amp);
		}
	).add;
)



// the midi defs binding to ~notes
(
MIDIdef.noteOn(\kb_on, {
	arg vel, num, chan, src;
	["note on:",vel, num, chan, src].postln;
	~notes[num] = Synth.new(\directAttack,
		[\freq, num.midicps, \amp,vel.linexp(1,127,0.01,0.25), \ccv0, ~ccv[0]]);
	~notes1[num] = Synth.new(\mysynth,
		[\freq, num.midicps, \amp,vel.linexp(1,127,0.01,0.25), \ccv0, ~ccv[0]]);

//	~notes[num].set(\gate, 1);
});

MIDIdef.noteOff(\kb_off, {
	arg vel, num, chan, src;
	["note off:",vel, num, chan, src].postln;
	~notes[num].set(\gate, 0);
	~notes[num] = nil;
	~notes1[num].set(\gate, 0);
	~notes1[num] = nil;
});
)


// the midi (control) defs binding to ccv
(
~cc = 8.collect({arg i;
	MIDIdef.cc(~ccs[i], {
		arg vel, num, chan, src;
		//[vel, num, chan, src].postln;
		// ~ccv.postln;
		~ccv[num-16] = vel.linlin(0,127,0,1);
		~notes.do({ arg item, i;
			if(item != nil, {
				item.set(\ccv0, ~ccv[0]); // seems to result in race condition with noteoff.
			}, {
				//
			});
		});
	}, chan:0);
});
)

// status gui for ccv
(
Window.closeAll;
w = Window.new("control view", Rect.new(400, 600, 190, 110)).front;

~ccknobs = 8.collect({
	arg i;
	var size = 30, margin=10, r0, r1;
	r0 = Rect(20 + ((i%4)*(size + margin)), 20 + ((i/4).trunc*(size + margin)), size, size);
	Knob.new(w, r0);
});
)

// periodic tasks
(
AppClock.clear;
AppClock.sched(0.0,{ arg time;
	8.do({arg i;
		// update knobs
		~ccknobs[i].value = ~ccv[i];
	});
	0.05; // return delta t for next scheduled execution.
});
)

~ccv.postln;





