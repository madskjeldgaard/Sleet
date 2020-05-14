/*

TODO: 
- Add method to change number of channels

*/
Sleet {
	classvar <singleton;
	var <classpath, <modules, <synthdefs, <list, <numChannels;

	*new { | numChannels=2|
		if(singleton.isNil or: { numChannels != singleton.numChannels }, {

			if( numChannels != singleton.numChannels && singleton.notNil, { 
				"Changing number of channels in Sleet singleton from % to %".format(singleton.numChannels, numChannels).poststamped 
			});

			singleton = super.new.init( numChannels );
		}, {
			"Sleet instance already exists in .singleton".poststamped;
		});

		^singleton;
	}

	init { | numChans |
		classpath = Main.packages.asDict.at('Sleet');
		modules = IdentityDictionary.new;
		list=IdentityDictionary.new;
		numChannels=numChans;

		this.loadModulesToDict(numChannels);
		this.makeSynthDefs(numChannels);
		this.makeList();
	}

	crawl{ |doFunction|
		modules.keysValuesDo{|category, categoryContent|
			// Modules
			if(categoryContent.size > 0, {
				categoryContent.keysValuesDo{|moduleName, moduleContent|
					doFunction.value(moduleName, moduleContent)	
				}
			})
		}
	}

	postInfo{
		// Categories
		"These are the modules available in Sleet right now:".poststamped;
		this.crawl({|moduleName, moduleContent|
			( "\t\t\t" ++ moduleName).postln;
			moduleContent.argNames.do{|a| "\t\t\t\targ: %".format(a).postln};
		})
	}

	loadModulesToDict{|numChannels|
		var folder = classpath +/+ "modules";

		// Iterate over a folder of files containing sleet modules
		PathName(folder).filesDo{|f|
			var ext = f.extension;
			var name = f.fileNameWithoutExtension.asSymbol;

			// Only normal SuperCollider files
			if(ext == "scd", {
				var contents;
				//"found module file: %".format(name).poststamped;

				contents = f.fullPath.load.value(numChannels);

				modules.put(name, contents)
			})
		}

		^modules
	}

	get{|name|
		^list[name]
	}

	makeList{
		// Category
		modules.keysValuesDo{|category, catContent|
			// Modules in category
			catContent.keysValuesDo{|moduleName, moduleContent|
				list.put(moduleName, moduleContent)
			}
		};

		^list
	}

	storeSynths{
		synthdefs.do{|sd|
			sd.store
		}
	}

	makeSynthDefs{|numChannels=2|

		// Category
		modules.keysValuesDo{|category, catContent|

			// Modules in category
			catContent.keysValuesDo{|moduleName, moduleContent|
				var def, defname;
				defname = moduleName.asString ++ numChannels;

				//"loading module % from category % ".format(moduleName, category).poststamped;

				// Create synthdef
				def = SynthDef(defname.asSymbol, { |in, out, wet=1.0|
					var insig = In.ar(in, numChannels);
					var sig = SynthDef.wrap(moduleContent, prependArgs: [insig]);

					XOut.ar(out, wet, sig);
				}).add;

				// Add to global synthdef array of instance
				synthdefs = synthdefs.add(def);

				//"SynthDef added: SynthDef('%')".format(defname).poststamped;

			}
		}

	}
}

// Dynamically switch between fx chains
SleetPatcher {
	var <nodeproxy, <chain, <sleet, <>firstIndex, <lastIndex=60;

	*new { |addtonodeproxy, fxchain, patchFromIndex=50|
		^super.new.init(addtonodeproxy, fxchain, patchFromIndex)
	}

	init{|addtonodeproxy, fxchain, patchFromIndex|
		nodeproxy = addtonodeproxy;
		chain = fxchain;
		sleet = Sleet.new(numChannels:nodeproxy.numChannels );
		firstIndex = patchFromIndex;

		if(this.channelsEqual.not, {
			"Incompatible channel numbers. Sleet has % channels and Nodeproxy has % channels".format(
				sleet.numChannels, nodeproxy.numChannels
			).error 
		}, {
			this.addChain(chain)
		});
	}

	clearChainFromProxy{
		(firstIndex..lastIndex).do{|index|
			nodeproxy[index] = nil
		}
	}

	channelsEqual{
		^(nodeproxy.numChannels == sleet.numChannels)	
	}

	addChain{|fxchain|
		this.clearChainFromProxy;
		chain = fxchain;

		// Add chain
		chain.do{|fxname, fxindex|
			var index = firstIndex + fxindex; // Offset index

			"Adding % to slot % in nodeproxy".format(fxname, index).postln;
			// nodeproxy[index].postln;
			nodeproxy[index] = \kfilter -> sleet.get(fxname.asSymbol);
			// nodeproxy[index] = \filter -> {|in| in};

		};

		// Set last index for last fx
		// This is used when adding new fx chain
		lastIndex = firstIndex + chain.size;
	}

	addChainShuffled{|fxchain|
		this.addChain(fxchain.scrambled)
	}
}
