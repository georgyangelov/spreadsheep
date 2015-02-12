window.jQuery(function($) {
    'use strict';

    window.HandsontablePlugins.RemoteSelections.register();

    var container = document.getElementById('table'),
        table = new Handsontable(container, {
            startRows: 100,
            startCols: 37,
            rowHeaders: true,
            // stretchH: 'all',
            minSpareRows: 1,
            colHeaders: true,
            contextMenu: false,

            manualColumnResize: true,
            manualRowResize: true
        });

    // DEBUG
    window.table = table;

    function cell_objects_to_array(cells) {
        return _.map(cells, function(cell) {
            return [cell.row, cell.column, cell.content];
        });
    }

    function cell_array_to_objects(cells) {
        return _.map(cells, function(cell) {
            return {
                row: cell[0],
                column: cell[1],
                content: cell[3]
            };
        });
    }

    function randomColor() {
        return Please.make_color({
            golden: false,

            saturation: 0.7,
            value: 0.7
        });
    }

    // WebSocket initialization
    var socket = new JSONSocket('ws://' + window.location.host + '/socket/sheet/' + window.state.sheet_id);

    socket.on('open', function() {
        console.log('Socket connected');
    });

    socket.on('close', function() {
        console.log('Socket connection lost. Trying to reconnect...')

        // Try to reconnect after 5 seconds
        setTimeout(function() {
            socket.connect();
        }, 5000);
    });

    socket.on('message', function(message) {
        console.log('got message', message);
        if (message.type === 'cell_changes') {
            table.setDataAtCell(cell_objects_to_array(message.changes), 'automatic');
        } else if (message.type === 'new_user') {
            table.remote_selections.add(message.socket_id, randomColor());

            if (message.selection) {
                table.remote_selections.move(
                    message.socket_id,
                    message.selection.start.row,
                    message.selection.start.column,
                    message.selection.end.row,
                    message.selection.end.column
                );
            }
        } else if (message.type === 'remove_user') {
            table.remote_selections.remove(message.socket_id);
        } else if (message.type === 'selection_change') {
            table.remote_selections.move(
                message.socket_id,
                message.start.row,
                message.start.column,
                message.end.row,
                message.end.column
            );
        }
    });

    socket.connect();

    // Load initial data
    $.get('/sheet/' + window.state.sheet_id + '/cells').then(function(cells) {
        table.setDataAtCell(cell_objects_to_array(cells), 'automatic');
    });

    // Handsontable event handlers
    table.addHook('afterChange', function(changes, source) {
        if (source === 'automatic') {
            return;
        }

        socket.send({
            type: 'cell_changes',
            changes: cell_array_to_objects(changes)
        });
    });

    table.addHook('afterSelection', function(row1, col1, row2, col2) {
        socket.send({
            type: 'selection_change',
            start: {
                row: row1,
                column: col1
            },
            end: {
                row: row2,
                column: col2
            }
        });
    });

    table.addHook('afterDeselect', function() {
        socket.send({
            type: 'selection_change',
            start: {
                row: null,
                column: null
            },
            end: {
                row: null,
                column: null
            }
        });
    });
});
