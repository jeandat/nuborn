define( "app.core.Base", function ( require, exports, module ) {

    'use strict';

    var $ = jQuery;

    /**
     * @class app.manager.SettingsManager
     * Base class for every other class.
     */
    module.exports = Object.subClass( {

        /**
         * @Constructor
         * @param {Object} settings Initialize object with a group of properties.
         */
        init: function ( settings ) {
            console.log( "Base" );
        },

        /**
         * Set or get defaults settings for this component.
         */
        defaults: function ( defaults ) {

        },

        /**
         * Set or get component's settings.
         */
        settings: function ( settings ) {

        }
    } );

} );