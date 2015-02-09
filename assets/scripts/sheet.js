window.jQuery(function($) {
    'use strict';

    var container = document.getElementById('table'),
        handsontable = new Handsontable(container, {
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

});
