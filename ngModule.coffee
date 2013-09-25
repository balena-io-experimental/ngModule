define ->
	ngModule = (options) ->
		a = [1,2,3,4]
		b = [0, a...]

		naivePluralizer = (word) ->
			if (word[-1..] == 'y') then (word[...-1] + 'ies') else (word + 's')

		defineFromObj = (moduleName, obj) ->
			keys = (key for own key of obj.define)
			vals = (val for own key, val of obj.define)
			define(moduleName, vals, eval("(function(#{keys.join(', ')}){return #{obj.code.toString()}})"))

		defineFromFunc = (moduleName, func) ->
			define(moduleName, [], eval("(function(){return #{func.toString()}})"))

		requireKeys = (key for own key of options.requires)
		requireVals = (val for own key, val of options.requires)

		thingTypes = ['animation', 'constant', 'controller', 'directive', 'factory', 'filter', 'provider', 'service', 'value']
		things = ['config', 'controller', 'run']

		dependencies = ['angular']

		funcBody = "angular.module('#{options.name}', #{JSON.stringify(requireKeys)})\n"
		argnum = 1

		# process thing groups
		for thingType in thingTypes
			for own item, dependency of options[naivePluralizer(thingType)]
				switch typeof dependency
					when "string"
						dependencies.push(dependency)
						funcBody += "\t.#{thingType}('#{item}', arguments[#{argnum++}])\n"
					when "object"
						defineFromObj(item, dependency)
						dependencies.push(item)
						funcBody += "\t.#{thingType}('#{item}', arguments[#{argnum++}])\n"
					when 'function'
						defineFromFunc(item, dependency)
						dependencies.push(item)
						funcBody += "\t.#{thingType}('#{item}', arguments[#{argnum++}])\n"
					else
						console.warn 'not implemented', item

		for item in things when options[item]
			if typeof options[item] == 'string'
				dependencies.push(options[item])
				funcBody += "\t.#{item}(arguments[#{argnum++}])\n"
			else
				console.warn 'not implemented', options[item]

		funcBody = funcBody[...-1] # remove redundant newline

		dependencies = dependencies.concat(requireVals)
		func = new Function(funcBody)

		#console.log(dependencies, func)
		define(dependencies, func)

	exports = ngModule
	window.ngModule = exports
	return exports