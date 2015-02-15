window.initialize_sheet = function() {
    'use strict';

    window.HandsontablePlugins.RemoteSelections.register();

    var container = document.getElementById('table'),
        row_sizes = [],
        column_sizes = [],
        table = new Handsontable(container, {
            startRows: 100,
            startCols: 37,
            rowHeaders: true,
            // stretchH: 'all',
            minSpareRows: 1,
            colHeaders: true,
            contextMenu: false,

            manualColumnResize: true,
            manualRowResize: true,

            formulas: true
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

    // Initialize the user list component
    var user_list = React.render(
        React.createElement(UserList, null),
        document.getElementById('user-list')
    );

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
        if (message.type === 'cell_changes') {
            table.setDataAtCell(cell_objects_to_array(message.changes), 'automatic');
        } else if (message.type === 'new_user') {
            var color = randomColor();

            table.remote_selections.add(message.socket_id, color);
            user_list.add(message.socket_id, message.user.full_name, color);

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
            user_list.remove(message.socket_id);
        } else if (message.type === 'selection_change') {
            table.remote_selections.move(
                message.socket_id,
                message.start.row,
                message.start.column,
                message.end.row,
                message.end.column
            );
        } else if (message.type === 'row_column_resize') {
            if (message.row_column_type === 'row') {
                row_sizes[message.index] = message.width;
            } else {
                column_sizes[message.index] = message.width;
            }

            table.updateSettings({
                manualRowResize: row_sizes,
                manualColumnResize: column_sizes
            });
        }
    });

    socket.connect();

    // Load initial data
    $.get('/sheet/' + window.state.sheet_id + '/data').then(function(data) {
        table.setDataAtCell(cell_objects_to_array(data.cells), 'automatic');

        row_sizes = data.row_sizes;
        column_sizes = data.column_sizes;

        table.updateSettings({
            manualRowResize: row_sizes,
            manualColumnResize: column_sizes
        });
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

    table.addHook('afterRowResize', function(row, size) {
        row_sizes[row] = size;

        socket.send({
            type: 'row_column_resize',
            row_column_type: 'row',
            index: row,
            width: size
        });
    });

    table.addHook('afterColumnResize', function(column, size) {
        column_sizes[column] = size;

        socket.send({
            type: 'row_column_resize',
            row_column_type: 'column',
            index: column,
            width: size
        });
    });
};
