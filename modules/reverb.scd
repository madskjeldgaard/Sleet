{|numchans|
	"loading reverb.scd".poststamped;

	(
		freeverb: {|in, verbtime=20, damp=0.5|
			Array.fill(numchans, {|cNum|
				FreeVerb1.ar(in[cNum], verbtime, damp)
			})
		},
		cheeseverb: {|in,fbamount=0.5, highcut=5500, lowcut=50, verbtime=10, modfreq=0.1, damp=0.2, modamount=0.5|
			Array.fill(numchans, {|cNum|
				Cheeseverb1.ar(in[cNum], fbamount, highcut, lowcut, verbtime, modfreq, damp, modamount)
			})
		} 
	)
}
