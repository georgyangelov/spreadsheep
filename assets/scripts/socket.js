window.JSONSocket = function(url) {
    'use strict';

    var socket,
        handlers = {
            open: [],
            message: [],
            close: [],
            error: []
        };

    function send_event(event, data) {
        _.each(handlers[event], function(handler) {
            handler.apply(undefined, data);
        });
    }

    return {
        get_socket: function() {
            return socket;
        },

        on: function(event, handler) {
            if (!(event in handlers)) {
                throw new Error('Unknown event ' + event);
            }

            handlers[event].push(handler);
        },

        connect: function() {
            socket = new WebSocket(url);

            socket.onopen = function() {
                send_event('open', [this]);
            }.bind(this);

            socket.onmessage = function(message) {
                send_event('message', [JSON.parse(message.data), this, message]);
            }.bind(this);

            socket.onclose = function() {
                send_event('close', [this]);
            }.bind(this);

            socket.onerror = function() {
                send_event('error', [this]);
            }.bind(this);
        },

        send: function(object) {
            socket.send(JSON.stringify(object));
        },

        close: function() {
            socket.close();
        }
    };
};
