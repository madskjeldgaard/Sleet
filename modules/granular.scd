{|numchans|
	"loading granular.scd".poststamped;

	(
		// From SonicPi via SuperDirt
		octer: {|in, octer=0.5, octersub=0.0, octersubsub=0.0|
			var sig, oct1, oct2, oct3, sub;
			sig = in;
			oct1 = 2.0 * LeakDC.ar( abs(sig) );
			sub = LPF.ar(sig, 440);
			oct2 = ToggleFF.ar(sub);
			oct3 = ToggleFF.ar(oct2);
			sig = SelectX.ar(octer, [sig, octer * oct1, DC.ar(0)]);
			sig = sig + (octersub * oct2 * sub) + (octersubsub * oct3 * sub);
			sig
		},
		pitchshift: {|in, winsize=0.25, pitch=0.75, pd=0.001, td=0.001|
			Array.fill(numchans, {|cNum|
				PitchShift.ar(
					in[cNum],  
					windowSize: {rrand(0.95,1.0)} * winsize,
					pitchRatio: {rrand(0.95,1.0)} * pitch,  
					pitchDispersion:{rrand(0.95,1.0)} *  pd,  
					timeDispersion:{rrand(0.95,1.0)} * td
				)
			})
		},	
		// This one was stolen from David Granström's SuperPrism project,
		// another big inspiration: github.com/davidgranstrom/SuperPrism
		grainfb: {|in, fbgrainsize = 0.25, fbgrainrand = 0.8, fbGain = 0.1|
			var bufLength = 1.0;
			var localBuf = LocalBuf(
				bufLength * SampleRate.ir, 
				numchans
			).clear;

			var warp = Warp1.ar(
				numchans,
				localBuf,
				LFSaw.ar(1/bufLength).linlin(-1.0,1.0,0.0, 1.0),
				Drand([ 2, - 2 ], inf),
				fbgrainsize.linlin(0.0, 1.0, 0.0, 2.0),
				-1,
				2,
				fbgrainrand.linlin(0.0, 1.0, 0.2, 1.0),
				4
			);

			// record w/ feedback
			RecordBuf.ar(tanh(in + HPF.ar(tanh(warp * fbGain), 30)), localBuf);

			warp = warp.tanh;
			warp = HPF.ar(warp * 0.5, 150);
			warp.sanitize;
		}
	)
}
