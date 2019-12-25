{|numchans|
	"loading timbre.scd".poststamped;

	(
		freqshift: {|in, freq=0.01, phase=0| 
			Array.fill(numchans, {|cNum|
				FreqShift.ar(in[cNum], freq * {rrand(0.95,1.0)},  phase: phase * {rrand(2pi,-2pi)})
			})
		},
		distortion: {|in, amp=0.5, smooth=0.5|
				Array.fill(numchans, {|cNum|
					CrossoverDistortion.ar(in[cNum], amp, smooth)
				})
			}
	)
}
