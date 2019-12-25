{|numchans|
	"loading granular.scd".poststamped;

	(
		pitchshift: {|in, winsize=0.25, pitch=0.75, pd=0.001, td=0.001|
			Array.fill(numchans, {|cNum|
				PitchShift.ar(in[cNum],  
				windowSize: {rrand(0.95,1.0)} * winsize,
				pitchRatio: {rrand(0.95,1.0)} * pitch,  
				pitchDispersion:{rrand(0.95,1.0)} *  pd,  
				timeDispersion:{rrand(0.95,1.0)} * td
			)
		})
	},	
)
}
