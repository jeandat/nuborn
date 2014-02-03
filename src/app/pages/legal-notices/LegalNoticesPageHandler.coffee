define "app.pages.LegalNoticesPageHandler", ( require, exports, module ) ->

	'use strict'

	$ = jQuery
	log = require "#log"
	AppPageHandler = require "app.pages.AppPageHandler"

	###*
	@class app.pages.LegalNoticesPageHandler
	@extends app.pages.AppPageHandler
	The Page Handler of the legalNotices page.
	###
	class LegalNoticesPageHandler extends AppPageHandler

		###*
		@override
		@inheritdoc
		###
		constructor: () ->
			super
				id: "legalNotices"
				templateId: "legal-notices"

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


	module.exports = LegalNoticesPageHandler

