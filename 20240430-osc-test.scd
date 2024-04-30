
// ------------------------------------------------------------

(
SynthDef.new(\mysynth, {
	arg freq;
	var sig;

	freq = Lag.kr(freq,lagTime: 1);
	sig = Saw.ar(freq,0.2!2);

	sig = LPF.ar(sig, 1200);

	Out.ar(0,sig);
}).add;
)


// ------------------------------------------------------------

(
SynthDef(\sillyVoice, { arg
	out = 0, pan = 0, freq = 220, offset = 0, phase = 0, amp = 0.5, vibSpeed = 6, vibDepth = 0.04, vowel = 0, att = 0.05, rel = 0.1, lag = 1, gate = 1, curve = -4, kAmp = 0.05, kRel = 1;

	var vibrato, env, kEnv, in, va, ve, vi, vo, vu, snd, outfreq;


	offset = Lag.kr(offset, 1);
	outfreq = freq+offset;

	vibrato = SinOsc.kr(freq: vibSpeed, phase:phase).range(1 / (1 + vibDepth), (1 + vibDepth));

	env = Env.asr(
		attackTime: att,
		sustainLevel: amp,
		releaseTime: rel,
		curve: curve).kr(gate: gate, doneAction: 2);

	kEnv = Env.perc(attackTime: att, releaseTime: kRel, level: kAmp, curve: curve).kr;

	in = Saw.ar(freq: Lag.kr(in: outfreq, lagTime: lag) * vibrato, mul: env);

	in = in + WhiteNoise.ar(kEnv);

	va = BBandPass.ar(
		in: in,
		freq: [ 600,  1040,   2250,   2450,   2750  ],
		bw:   [ 0.1,  0.067,  0.049,  0.049,  0.047 ],
		mul:  [ 1,    0.447,  0.355,  0.355,  0.1   ]);

	ve = BBandPass.ar(
		in: in,
		freq: [ 400,  1620,   2400,   2800,   3100  ],
		bw:   [ 0.1,  0.049,  0.042,  0.043,  0.039 ],
		mul:  [ 1,    0.251,  0.355,  0.251,  0.126 ]);

	vi = BBandPass.ar(
		in: in,
		freq: [ 250,   1750,   2600,   3050,   3340  ],
		bw:   [ 0.24,  0.051,  0.038,  0.039,  0.036 ],
		mul:  [ 1,     0.032,  0.158,  0.079,  0.04  ] );

	vo = BBandPass.ar(
		in: in,
		freq: [ 400,  750,    2400,   2600,   2900  ],
		bw:   [ 0.1,  0.107,  0.042,  0.046,  0.041 ],
		mul:  [ 1,    0.282,  0.089,  0.1,    0.01  ]);

	vu = BBandPass.ar(
		in: in,
		freq: [ 350,    600,    2400,   2675,   2950  ],
		bw:   [ 0.114,  0.133,  0.042,  0.045,  0.041 ],
		mul:  [ 1,      0.1,    0.025,  0.04,   0.016 ]);

	snd = SelectX.ar(which: Lag.kr(in: vowel, lagTime: lag), array: [va, ve, vi, vo, vu]);

	snd = Mix.ar(snd);

    Out.ar(out, Pan2.ar(snd, pan));

},
metadata: (
	credit: "Bruno Ruviaro?",
	category: \misc,
	tags: [\pitched, \vocal]
	)
).add;
)

// --------------------------------------------------------------
(
SynthDef("werkit", {
	arg out = 0, pan = 0.0, freq = 440, offset = 0, amp = 0.1, gate = 1, cutoff = 100, rq = 0.1, att = 0.01, dec = 0, sus = 1, rel = 1, delay = 0.3;
	var source, filter, env, snd, delayEnv, outfreq;


	offset = Lag.kr(offset, 1);
	outfreq = freq+offset;

	source = WhiteNoise.ar;
	filter = BLowPass4.ar(source, outfreq , rq) * 0.3;
	env = EnvGen.ar(
		envelope: Env.adsr(att, dec, sus, rel, amp),
		gate: gate,
		doneAction: 2);
	snd = (0.7 * filter + (0.3 * filter.distort)) * env;
	Out.ar(out, Pan2.ar(snd, pan));
}).add;
)


// --------------------------------------------------------------
// The actual OSC stuff
// --------------------------------------------------------------

thisProcess.openUDPPort(44718); // attempt to open a port
thisProcess.openPorts; // list all open ports

~synG = Group.new;
[400,700,790,1530].do({|f| Synth.new(\sillyVoice, [\freq, f,\vibSpeed, 6, \phase,0],~synG);});

(
o = OSCFunc(
	{ arg msg, time, addr, recvPort;
		// [msg, time, addr, recvPort].postln;
		f = msg[1].asFloat.clip(0,180).linlin(0,180,1,1000);
		f.postln;
		~synG.set(\offset,f);
}, '/unity/rotation');
)

// cleanup
~synG.free;
o.free;
