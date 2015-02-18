window.HandsontablePlugins = window.HandsontablePlugins || {};
window.HandsontablePlugins.ColorRenderer = function() {
    'use strict';

    var DEFAULT_COLOR_DATA = {bg: '#ffffff', fg: '#000000'},
        colorData = {};

    function getColorData(row, col) {
        var rowData = colorData[row];

        if (rowData) {
            return rowData[col] || DEFAULT_COLOR_DATA;
        } else {
            return DEFAULT_COLOR_DATA;
        }
    }

    return {
        renderer: function(instance, td, row, col, prop, value, cellProperties) {
            var colorData = getColorData(row, col);

            Handsontable.TextCell.renderer.apply(this, arguments);

            td.style.color = colorData.fg;
            // Stupid !important styles
            // td.style.backgroundColor = colorData.bg;
            if (colorData.bg !== DEFAULT_COLOR_DATA.bg) {
                td.style.cssText += ';background-color: ' + colorData.bg + ' !important;';
            }
        },

        setColorData: function(row, col, bg, fg) {
            var rowData = colorData[row] = colorData[row] || {},
                oldData = rowData[col] || DEFAULT_COLOR_DATA;

            rowData[col] = {bg: bg || oldData.bg, fg: fg || oldData.fg};
        },

        getColorData: getColorData
    };
};
