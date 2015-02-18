window.HandsontablePlugins = window.HandsontablePlugins || {};
window.HandsontablePlugins.StyleRenderer = function() {
    'use strict';

    var DEFAULT_DATA = {bg: '#ffffff', fg: '#000000', fontSize: 16, alignment: 'top_left'},
        HORIZONTAL_ALIGNMENT = {
            top_left:      'left',
            top_center:    'center',
            top_right:     'right',
            middle_left:   'left',
            middle_center: 'center',
            middle_right:  'right',
            bottom_left:   'left',
            bottom_center: 'center',
            bottom_right:  'right'
        },
        VERTICAL_ALIGNMENT = {
            top_left:      'top',
            top_center:    'top',
            top_right:     'top',
            middle_left:   'middle',
            middle_center: 'middle',
            middle_right:  'middle',
            bottom_left:   'bottom',
            bottom_center: 'bottom',
            bottom_right:  'bottom'
        },
        styleData = {};

    function getCellStyle(row, col) {
        var rowData = styleData[row];

        if (rowData) {
            return rowData[col] || DEFAULT_DATA;
        } else {
            return DEFAULT_DATA;
        }
    }

    return {
        renderer: function(instance, td, row, col, prop, value, cellProperties) {
            var styleData = getCellStyle(row, col);

            Handsontable.TextCell.renderer.apply(this, arguments);

            td.style.color = styleData.fg;
            td.style.fontSize = styleData.fontSize + 'px';
            td.style.lineHeight = 'normal';

            td.style.textAlign = HORIZONTAL_ALIGNMENT[styleData.alignment];
            td.style.verticalAlign = VERTICAL_ALIGNMENT[styleData.alignment];

            // Stupid !important styles
            // td.style.backgroundColor = styleData.bg;
            if (styleData.bg !== DEFAULT_DATA.bg) {
                td.style.cssText += ';background-color: ' + styleData.bg + ' !important;';
            }
        },

        setCellStyle: function(row, col, bg, fg, fontSize, alignment) {
            var rowData = styleData[row] = styleData[row] || {},
                oldData = rowData[col] || DEFAULT_DATA;

            rowData[col] = {
                bg: bg || oldData.bg,
                fg: fg || oldData.fg,
                fontSize: fontSize || oldData.fontSize,
                alignment: alignment || oldData.alignment
            };
        },

        getCellStyle: getCellStyle
    };
};
