{|numchans|
	"loading delay.scd".poststamped;

	(
		delay: {|in, delay=0.1, delayfb=0.33|
			Array.fill(numchans, {|cNum|
				CombC.ar(
					in[cNum], 
					1, 
					{rrand(0.98,1.0)} * delay.linlin(0.0,1.0,0.005,1.0), 
					delayfb.linexp(0.0,1.0,1.0,8.0)
				)
			})
		},
		// Phaser taken from SuperDirt
		// https://github.com/musikinformatik/SuperDirt/blob/develop/synths/core-synths.scd
		phaser: { |in, phaserrate = 1.0, phaserdepth = 0.5|
			Array.fill(numchans, {|cNum|
				var phase =  LFPar.kr(phaserrate.linexp(0.0,1.0,0.1,100.0) * cNum.linlin(0, numchans, 0.95,1.05)).range(0.0088, 0.01);
				phaserdepth = phaserdepth.clip(0, 1);

				AllpassL.ar(in[cNum], 4, phase, 0, phaserdepth);
			})
		},
		// Taken from Thor Magnussons book Scoring Sound: https://leanpub.com/ScoringSound/read#leanpub-auto-flanger 
		flanger: { |in, flangdelay=0.1, flangdepth=0.5, flangrate=0.06, flangfb=0.1|
			var input, maxdelay, maxrate, dsig, mixed, local;
			maxdelay = 0.013;
			maxrate = 10.0;
			input = in;
			local = LocalIn.ar(numchans);

			dsig = Array.fill(numchans, {|cNum|
				AllpassC.ar( 
					input[cNum] + (local[cNum] * flangfb),
					maxdelay,
					LFTri.kr( 
						flangrate.linexp(0.0,1.0,0.00001, maxrate),
						0,
						flangdepth * maxdelay,
						flangdelay * maxdelay
					),
					0
				);
			});

			LocalOut.ar(dsig);
			dsig;
		},	
		chorus: {|in, chpredelay=0.08, chrate=0.05, chdepth=0.1, chphasediff=0.5|
			var sig, numDelays = 4;

			sig = Array.fill(numchans, {|cNum|
				var input = in[cNum] * numDelays.reciprocal;
				var modulators = Array.fill(numDelays, { arg i; 
					LFPar.kr(chrate.linexp(0.0,1.0,0.001,10.0) * {rrand(0.94, 1.06)}, chphasediff * i, chdepth, chpredelay)
				});
				DelayC.ar(input, 0.2, modulators).sum;  
			});

			sig
		},
		timemachine: {|in, offset=0, reclvl=0.5, prelvl=0.5, timerate=0.5, fb=0.25, record=1, jumpToStart=1|
			var local = LocalBuf(44100 * 16, numChannels: numchans).clear;
			var sig;
			var feedback = LocalIn.ar(fb * in, numChannels: numchans).tanh;

			RecordBuf.ar(in + feedback, local, offset, reclvl, prelvl,  run: record,  loop: 1.0,  trigger: jumpToStart,  doneAction: 0);

			sig = PlayBuf.ar(numchans, local, timerate.linlin(0.0,1.0,(-10.0),10.0), 1.0, 0.0, 1.0, doneAction: 0);
			sig = LeakDC.ar(sig);

			LocalOut.ar(sig);

			sig
		},
		// Same as above but using external buffer which you can then play with in patterns, etc.
		timemachine_ext: {|in, buffer=0, offset=0, reclvl=0.5, prelvl=0.5, timerate=0.5, fb=0.25, record=1, jumpToStart=1|
			var local = buffer;
			var sig;
			var feedback = LocalIn.ar(fb * in, numChannels: numchans).tanh;

			RecordBuf.ar(in + feedback, local, offset, reclvl, prelvl,  run: record,  loop: 1.0,  trigger: jumpToStart,  doneAction: 0);

			sig = PlayBuf.ar(numchans, local, timerate.linlin(0.0,1.0,(-10.0),10.0), 1.0, 0.0, 1.0, doneAction: 0);
			sig = LeakDC.ar(sig);

			LocalOut.ar(sig);

			sig
		}
	)
}
