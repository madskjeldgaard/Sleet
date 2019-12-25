Sleet {
	var <quarkpath, <modules, <synthdefs;

	*new { | numChannels=2, argb|
		^super.new.init( numChannels, argb );
	}

	init { | numChannels, argb |
		quarkpath = Quark("Sleet").localPath;
		modules = IdentityDictionary.new;

		this.loadModulesToDict(numChannels);
		this.makeSynthDefs(numChannels);
	}

	loadModulesToDict{|numChannels|
		var folder = quarkpath +/+ "modules";

		// Iterate over a folder of files containing sleet modules
		PathName(folder).filesDo{|f| 
			var ext = f.extension;
			var name = f.fileNameWithoutExtension.asSymbol;

			// Only normal SuperCollider files
			if(ext == "scd", { 
				var contents;
				"found module file: %".format(name).poststamped;

				contents = f.fullPath.load.value(numChannels);

				modules.put(name, contents)
			})
		}

		^modules
	}

	makeSynthDefs{|numChannels=2|

		// Category
		modules.keysValuesDo{|category, catContent|

			// Modules in category
			catContent.keysValuesDo{|moduleName, moduleContent|
				var def, defname;
				defname = moduleName.asString ++ numChannels;

				"loading module % from category % ".format(moduleName, category).poststamped;

				// Create synthdef
				def = SynthDef(defname.asSymbol, { |in, out, wet=1.0|
					var insig = In.ar(in, numChannels);
					var sig = SynthDef.wrap(moduleContent, prependArgs: [insig]);

					XOut.ar(out, wet, sig);
				});

				// Add to global synthdef array of instance
				synthdefs = synthdefs.add(def);

				"SynthDef added: SynthDef('%')".format(defname).poststamped;

			}
		}

	}
}
