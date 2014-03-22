( () ->

    'use strict'

    ###
    Callback function called when the DOM is ready.
    ###
    ready = () ->

        $ = jQuery

        # Default logger
        log = require "#log"

        # Utilities
        BrowserUtils = require "utils.BrowserUtils"

        app = require "app"

        # Pure web
        if !BrowserUtils.isCordova()
            log.i "Used as a Web App" if INFO
            app.init()
        # Cordova
        else
            log.i "Used as a Hybrid App" if INFO
            document.addEventListener "deviceready", app.init.bind app


    # Wwhen the Document is ready, GO GO GO
    document.addEventListener "DOMContentLoaded", ready

).call()