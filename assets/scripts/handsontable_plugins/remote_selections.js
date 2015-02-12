window.HandsontablePlugins = window.HandsontablePlugins || {};
window.HandsontablePlugins.RemoteSelections = function(instance, walkontableConfig) {
    'use strict';

    var selections = {};

    return {
        add: function(id, color) {
            if (selections[id]) {
                this.remove(id);
            }

            var selection = new window.WalkontableSelection({
                className: 'remote',
                border: {
                    width: 2,
                    color: color
                }
            });

            selections[id] = selection;

            walkontableConfig.selections.push(selection);
            instance.render();
            selection.draw(instance.view.wt);
        },

        remove: function(id) {
            var selection = selections[id];

            if (!selection) {
                return;
            }

            walkontableConfig.selections.splice(
                walkontableConfig.selections.indexOf(selection),
                1
            );

            selection.clear();
            instance.render();
            selection.draw(instance.view.wt);

            delete selections[id];
        },

        move: function(id, row, column, row2, column2) {
            var selection = selections[id];

            selection.clear();

            if (row !== null && column !== null) {
                selection.add({row: row, col: column});
            }

            if (typeof row2 !== 'undefined' && typeof column2 !== 'undefined' && (row != row2 || column != column2)) {
                selection.add({row: row2, col: column2});
            }

            selection.draw(instance.view.wt);
        }
    };
};

window.HandsontablePlugins.RemoteSelections.register = function() {
    'use strict';

    window.Handsontable.hooks.add('beforeInitWalkontable', function(walkontableConfig) {
        this.remote_selections = new window.HandsontablePlugins.RemoteSelections(this, walkontableConfig);
    });
};
