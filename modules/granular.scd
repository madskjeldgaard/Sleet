{|numchans|
	"loading granular.scd".poststamped;

	(
		pitchshift: {|in, winsize=0.25, pitch=0.75, pd=0.001, td=0.001|
			Array.fill(numchans, {|cNum|
				PitchShift.ar(
					in[cNum],  
					windowSize: {rrand(0.95,1.0)} * winsize,
					pitchRatio: {rrand(0.95,1.0)} * pitch.linexp(0.0,1.0,0.001,4.0),  
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
