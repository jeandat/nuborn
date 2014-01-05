define "app.pages.HelpPageHandler", ( require, exports, module ) ->

	'use strict'

	$ = jQuery
	Utils = require "nu.Utils"
	log = require "#log"
	NubornPageHandler = require "app.pages.NubornPageHandler"

	###*
	@class app.pages.HelpPageHandler
	@extends app.pages.NubornPageHandler
	The Page Handler of the help page.
	###
	class HelpPageHandler extends NubornPageHandler

		###*
		@override
		@inheritdoc
		###
		constructor: () ->
			super
				id: "help"

		###*
		@override
		@inheritdoc
		###
		createHtmlElements: () ->
			page = @html.page
			@html.menuButton = page.find "div.menu-button"

		###*
		@override
		@inheritdoc
		###
		createDataElements: () ->

		###*
		@override
		@inheritdoc
		###
		pageInit: ( event ) ->
			super event
			@handleMenuButton()

		###*
		@override
		@inheritdoc
		###
		pageShow: ( event, data ) ->
			super event, data

		###*
		Handle the menu button.
		###
		handleMenuButton: () ->
			# When tap on menu button, open menu panel
			@html.menuButton.on "tap", () ->
				menu = require "#menu"
				# Opening menu panel
				menu.toggleMenu()
				# Prevent bubbling
				return false


	module.exports = HelpPageHandler

