window.initialize_sheet = function() {
    'use strict';

    window.HandsontablePlugins.RemoteSelections.register();

    var container = document.getElementById('table'),
        row_sizes = [],
        column_sizes = [],
        styles = new window.HandsontablePlugins.StyleRenderer(),
        table = new Handsontable(container, {
            startRows: 100,
            startCols: 37,
            rowHeaders: true,
            // stretchH: 'all',
            minSpareRows: 1,
            colHeaders: true,
            contextMenu: false,
            outsideClickDeselects: false,

            manualColumnResize: true,
            manualRowResize: true,

            formulas: true,

            cells: function(row, col, prop) {
                this.renderer = styles.renderer;
            }
        });

    // DEBUG
    window.table = table;

    function cell_objects_to_array(cells) {
        return _(cells).filter(function(cell) {
            return typeof cell.content !== 'undefined';
        }).map(function(cell) {
            return [cell.row, cell.column, cell.content];
        }).value();
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

    function set_styles_for_cells(cells) {
        var has_style_changes = false;
        _.each(cells, function(cell) {
            if (cell.background_color || cell.foreground_color || cell.font_size || cell.alignment) {
                styles.setCellStyle(cell.row, cell.column, cell.background_color, cell.foreground_color, cell.font_size, cell.alignment);
                has_style_changes = true;
            }
        });

        if (has_style_changes) {
            table.render();
        }
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
            set_styles_for_cells(message.changes);
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

    // Initialize the color pickers
    function setCellStyles(background, foreground, fontSize, alignment) {
        var selectionRange = table.getSelectedRange();

        if (!selectionRange) {
            return;
        }

        var changes = [];
        selectionRange.forAll(function(row, column) {
            styles.setCellStyle(row, column, background, foreground, fontSize, alignment);

            changes.push({
                row: row,
                column: column,
                background_color: background,
                foreground_color: foreground,
                font_size: fontSize,
                alignment: alignment
            });
        });

        table.render();

        // Send color changes
        socket.send({
            type: 'cell_changes',
            changes: changes
        });
    }

    function setBackgroundColor(color) {
        setCellStyles(color, null, null, null);
    }

    function setForegroundColor(color) {
        setCellStyles(null, color, null, null);
    }

    function setFontSize(fontSize) {
        setCellStyles(null, null, fontSize, null);
    }

    function setAlignment(alignment) {
        setCellStyles(null, null, null, alignment);
    }

    var background_color_picker = React.render(
        React.createElement(ColorPicker, {title: 'Background color', initialColor: '#ffffff', onChange: setBackgroundColor}),
        document.getElementById('bg-color-picker')
    );

    var foreground_color_picker = React.render(
        React.createElement(ColorPicker, {title: 'Foreground color', initialColor: '#000000', onChange: setForegroundColor}),
        document.getElementById('fg-color-picker')
    );

    var font_size_picker = React.render(
        React.createElement(FontSizePicker, {initialSize: 16, onChange: setFontSize}),
        document.getElementById('font-size-picker')
    );

    var alignment_picker = React.render(
        React.createElement(AlignmentPicker, {initialAlignment: 'top_left', onChange: setAlignment}),
        document.getElementById('alignment-picker')
    );

    // Change the selected styles when the selection changes
    table.addHook('afterSelection', function(row1, col1, row2, col2) {
        var cellStyle = styles.getCellStyle(row1, col1);

        background_color_picker.setSelectedColor(cellStyle.bg);
        foreground_color_picker.setSelectedColor(cellStyle.fg);
        font_size_picker.setSelectedFontSize(cellStyle.fontSize);
        alignment_picker.setSelectedAlignment(cellStyle.alignment);
    });

    // Load initial data
    $.get('/sheet/' + window.state.sheet_id + '/data').then(function(data) {
        table.setDataAtCell(cell_objects_to_array(data.cells), 'automatic');

        set_styles_for_cells(data.cells);

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
