window.jQuery(function($) {
    'use strict';

    var container = document.getElementById('table'),
        table = new Handsontable(container, {
            startRows: 100,
            startCols: 37,
            rowHeaders: true,
            // stretchH: 'all',
            minSpareRows: 1,
            colHeaders: true,
            contextMenu: true,

            manualColumnResize: true,
            manualRowResize: true
        });

    // WebSocket initialization
    var socket = new JSONSocket('ws://' + window.location.host + '/socket/sheet/' + window.state.sheet_id);

    socket.on('open', function() {
        console.log('socket connected');
    });

    socket.connect();

    // Handsontable event handlers
    table.addHook('afterChange', function(changes) {
        changes = _.map(changes, function(change) {
            return {
                row: change[0],
                column: change[1],
                value: change[3]
            };
        });

        socket.send({
            type: 'change',
            changes: changes
        });
    });
});
