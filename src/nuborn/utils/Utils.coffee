define "nu.Utils", ( require, exports, module ) ->

	'use strict'

	$ = jQuery

	###*
	@class nu.Utils
	@singleton
	Utilities class.
	###
	Utils = {}

	###*
	Checks if Internet is reachable.
	@return {Boolean} The reachability of the internet
	###
	Utils.isNetworkAvailable = () ->
		if Utils.isCordova()
			return navigator.connection.type isnt Connection.NONE
		else
			return navigator.onLine

	###*
	Checks if the application is running with PhoneGap (Cordova)
	@return {Boolean} [description]
	###
	Utils.isCordova = () ->
		return window.cordova

	###*
	Checks if the device platform is Android.
	@return {Boolean}
	###
	Utils.isAndroid = () ->
		if Utils.isCordova()
			return device.platform is "Android"
		else
			return navigator.userAgent.match "Android"

	###*
	Checks if the device platform is iOS.
	@return {Boolean}
	###
	Utils.isIOS = () ->
		if Utils.isCordova()
			return device.platform is "iOS"
		else
			return navigator.userAgent.match( /(iPhone|iPod|iPad)/i ) isnt null

	###*
	Checks if the device platform is older than Android 4.
	@return {Boolean}
	###
	Utils.isOldAndroid = () ->
		return false if not Utils.isAndroid()
		return Utils.getOSVersion() < 4

	###*
	Checks if the device platform is older than iOS 5.
	@return {Boolean}
	###
	Utils.isOldIOS = () ->
		return false if not Utils.isIOS()
		return Utils.getOSVersion() < 5

	###*
	Gets the OS version. <br/>
	Supports Phonegap - web (iOS, Android). <br/>
	Needs more support.
	@return {Boolean}
	###
	Utils.getOSVersion = () ->
		# If the app is running on PhoneGap, ask for the device version
		# if Utils.isCordova()
		# 	return parseFloat device.version, 10
		# If it is a web app, ask the navigator user agent
		# else
		# Getting the user agent into a local variable
		agent = navigator.userAgent
		# iOS case
		if Utils.isIOS()
			# Removing the first part of the user agent
			versionIndex = agent.indexOf( "OS" ) + 2
			agent = agent.slice versionIndex
			# Removing the end of the user agent
			lastIndex = agent.indexOf( ")" ) is -1 ? 0 : agent.indexOf( ")" )
			agent = agent.substring 0, lastIndex
			# Replacing all underscores with points
			agent = agent.replace /_/g, "."
			# Parse the agent tg get the version as a float
			version = parseFloat agent
			# Returning the version
			return version
		# Android case
		else if Utils.isAndroid()
			# Removing the first part of the user agent
			versionIndex = agent.indexOf( "Android" ) + 7
			agent = agent.slice versionIndex
			# Removing the end of the user agent
			lastIndex = agent.indexOf( "" ) is -1 ? 0 : agent.indexOf( "" )
			agent = agent.substring 0, lastIndex
			# Parse the agent to get the version as a float
			version = parseInt agent
			# Returning the version
			return version
		else
			return NaN

	###*
	Simple utility method to add a class to the HTML tag which reflect the current browser/version.
	Of course, you should always use feature detection but there is time when you need to come back to an old
	user-agent snif. To use with great caution.
	Handle only iOS and Android like everything else in Nuborn.
	###
	Utils.decorateDOMWithBrowserClass = () ->
		browser = Utils.isIOS() ? "ios" : Utils.isAndroid() ? "android" : "other"
		version = Utils.getOSVersion()
		document.getElementsByTagName( "html" )[ 0 ].classList.add "#{browser}-#{version}"

	###*
	Loads JavaScript library contained in the js/lazy folder.
	@param  {String} library The library to load
	###
	Utils.loadLazyLib = ( library ) ->
		$.ajax
			url: "js/lazy/#{library}"
			dataType: "script"
			async: false

	Utils.blockEvent = ( event ) ->
		event.preventDefault()
		return false

	Utils.disableScroll = ( element ) ->
		el = element || document
		$( el ).on "touchmove", Utils.blockEvent

	Utils.enableScroll = ( element ) ->
		el = element || document
		$( el ).off "touchmove", Utils.blockEvent

	###*
	Deserialize the hash part of a URL.
	@param {String} hash Hash part of a URL. If null, window.location.hash is used.
	@return {Object}
	@return {String} return.name Hash name
	@return {Object} return.params Hash parameters
	###
	Utils.deserializeHash = ( hash ) ->
		result =
			name: ""
			params: ""

		hash = window.location.hash if not hash?.length?

		# Adding the raw source, can be useful for regexp searchs for instance
		result.hash = hash

		# No hash, no op.
		hashIndex = hash.lastIndexOf "#"
		return result if hashIndex < 0

		# Removing part before hash
		hash = hash.substr hashIndex

		# Is there hash parameters too ?
		questionMarkIndex = hash.indexOf "?"
		if questionMarkIndex < 0
			questionMarkIndex = hash.length
		else
			questionMarkIndex += 1

		# Extracting hash name
		result.name = hash.substr 0, questionMarkIndex
		if result?.name?.length? then result.name = result.name.replace /(.*#)|(\?.*)/g, ""

		# Extracting hash parameters
		result.params = Utils.deserializeParameters hash.substr questionMarkIndex

		return result

	###*
	Create a javascript object from a string hash which contains key/value parameters.
	@param {String} hash Minimum significant pattern is "?key=value"
	@return {Object} Simple key/value object.
	###
	Utils.deserializeParameters = ( hash ) ->

		result = {}
		if not hash?.length? then return result

		# Extracting hash parameters substring
		hashParameters = hash.substr hash.indexOf( "?" ) + 1
		if not hashParameters?.length? then return result

		# Parsing key=value pairs
		paramsArray = hashParameters.split "&"
		for param in paramsArray
			keyValueArray = param.split "="
			if not keyValueArray?.length? then return
			result[ keyValueArray[ 0 ] ] = decodeURIComponent keyValueArray[ 1 ]

		return result

	###*
	Create a new String object from a javascript object.
	@param {Object} parameters Simple key/value object.
	@return {String} following pattern "key1=value[&key2=value&...]"
	###
	Utils.serializeHashParameters = ( parameters ) ->

		result = ""
		return result if not parameters

		paramsArray = []
		for key, value of parameters
			paramsArray.push "#{key}=#{encodeURIComponent value}"

		result = paramsArray.join "&"
		return result

	###*
	Clone a javascript object.
	###
	Utils.clone = ( objectToClone ) ->
		return JSON.parse JSON.stringify objectToClone

	###*
	Shortcut for JSON.stringify(object, null, "    ")
	###
	Utils.toJSON = ( object ) ->
		clone = $.extend true, {}, object
		return JSON.stringify clone, null, "    "

	###*
	[Warning] Doesn't work if page handler is in prototype mode.
	Refresh a JQM page. If no page id provided, use the current active page.
	@param {String} pageId page ID.
 	Don't provide the character "#" in pageId.
	###
	Utils.refreshPage = ( pageId ) ->
		pageId = pageId || $.mobile.activePage.attr "id"
		DEBUG && log.i "Refreshing page: #{pageId}"
		$.mobile.changePage "##{pageId}",
			allowSamePageTransition: true
			transition: 'none'
			showLoadMsg: false
			changeHash: false

	###*
	If in a phonegap iOS app, hide native splashscreen.
	Else, hide web splashscreen.
	###
	Utils.hideSplashScreen = () ->
		# If the splashscreen is handled natively with iOS
		if Utils.isCordova() && navigator.splashscreen
			navigator.splashscreen.hide()
		else
			EventsDispatcher = require "nu.events.EventsDispatcher"
			SplashScreen = require "nu.widgets.SplashScreen"

			EventsDispatcher.instance.emit
				name: SplashScreen.EVENT_HIDE

	###*
	Install remote debugging scripts based on build based variables (uglify compilation).
	debug : true if compiling for development
	weinre : true if you want weinre support
	livereload : true if you want livereload support
	###
	Utils.installDebugScripts = () ->

		log = require( "#log" )

		###*
		Adding livereload support for development only.
		Refresh page automatically in conjunction with grunt watcher.
		Generate something like this in body :
		  <script src="http://<hostname>:35729/livereload.js"></script>
		###
		if DEBUG && LIVERELOAD
			lr = document.createElement 'script'
			hostname = REMOTE_HOST || window.location.hostname
			if 'https:' == window.location.protocol then protocol = 'https' else protocol = 'http'
			lr.src = "#{protocol}://#{hostname}:#{LIVERELOAD_PORT}/livereload.js"

			DEBUG && log.i "Installing Livereload script at: #{lr.src}"

			lr.type = 'text/javascript'
			lr.async = 'true'
			s = document.getElementsByTagName( 'script' )[ 0 ]
			s.parentNode.insertBefore lr, s

		###*
		Adding weinre support for development only.
		Allows remote debugging with Android default browser.
		Generate something like this in body :
		  <script src="http://<hostname>::8080/target/target-script-min.js#weinre"></script>
		###
		if DEBUG && WEINRE
			lr = document.createElement 'script'
			hostname = REMOTE_HOST || window.location.hostname
			if 'https:' == window.location.protocol then protocol = 'https' else protocol = 'http'
			lr.src = "#{protocol}://#{hostname}:#{WEINRE_PORT}/target/target-script-min.js#weinre"

			DEBUG && log.i "Installing Weinre script at: #{lr.src}"

			lr.type = 'text/javascript'
			lr.async = 'true'
			s = document.getElementsByTagName( 'script' )[ 0 ]
			s.parentNode.insertBefore lr, s

	###*
	Replace placeholders of form {x} in a string where x is a number >= 0.
	If no placeholders, return the string as is.
	@param {String} string
	@param {Array} params Array of values (converted as string)
	###
	Utils.replaceWith = ( string, params ) ->
		if not params then return string
		if not (params instanceof Array ) then params = [ params ]

		regex = /\{[0-9]\}/g
		for param in params
			m = regex.exec( string )
			if not m?
				return string
			else
				for match in m
					string = string.replace match, param

		return string

	###*
	Generate a random GUID.
	###
	Utils.guid = () ->
		return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, ( c ) ->
			r = Math.random() * 16 | 0
			if c == 'x' then v = r else v = ( r & 0x3 | 0x8 )
			return v.toString 16

	###*
	Generate a random color as HEX format.
	###
	Utils.randomHexColor = () ->
		return '#' + Math.floor( Math.random() * 16777215 ).toString( 16 )

	Utils.randomRgbaColor = ( opacity, hex ) ->
		hex = hex || Utils.randomHexColor().replace( '#', '' )
		r = parseInt( hex.substring( 0, 2 ), 16 )
		g = parseInt( hex.substring( 2, 4 ), 16 )
		b = parseInt( hex.substring( 4, 6 ), 16 )

		return "rgba(#{r},#{g},#{b},#{opacity})"

	Utils.randomHexColorWithLuminance = ( lum, hex ) ->
		hex = hex || Utils.randomHexColor()

		# Validate hex string
		hex = String( hex ).replace( /[^0-9a-f]/gi, '' )
		if hex.length < 6
			hex = hex[ 0 ] + hex[ 0 ] + hex[ 1 ] + hex[ 1 ] + hex[ 2 ] + hex[ 2 ]
		lum = lum || 0

		# Convert to decimal and change luminosity
		rgb = "#"
		for i in [0,1,2]
			c = parseInt( hex.substr( i* 2, 2 ), 16 )
			c = Math.round( Math.min( Math.max( 0, c + ( c * lum ) ), 255 ) ).toString( 16 )
			rgb += ( "00" + c ).substr( c.length )

		return rgb

	Utils.randomRgbColor = () ->
		hex = Utils.randomHexColor()
		result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec( hex )
		if result?
			return {
				r: parseInt( result[ 1 ], 16 )
				g: parseInt( result[ 2 ], 16 )
				b: parseInt( result[ 3 ], 16 )
			}
		else
			return result

	###*
	Return a random item from an array.
	###
	Utils.randomItemFromArray = ( array ) ->
		return array[ Math.floor( Math.random() * array.length ) ]

	# handle old browsers when JSON object is missing
	# if(!JSON || !JSON.stringify || !JSON.parse){
	# 	# creating JSON object
	# 	JSON = {}
	# 	# bind JSON stringify to jQuery JSON "toJSON" method
	# 	JSON.stringify = $.toJSON || function(object){
	# 		nu.log.e("JSON.stringify could not be loaded : returning empty string !")
	# 		return object instanceof Array ? "[]" : object instanceof Object ? "{}" : ""
	# 	}
	# 	# bind JSON stringify to jQuery JSON "evalJSON" method
	# 	JSON.parse = $.evalJSON || function(string){
	# 		nu.log.e("JSON.parse could not be loaded : returning empty object !")
	# 		return {}
	# 	}
	# }



	module.exports = Utils
