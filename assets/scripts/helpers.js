$(document).on('click', '[data-confirm]', function(event) {
    var $element = $(event.target);

    if (!confirm($element.data('confirm'))) {
        event.preventDefault();
        event.stopPropagation();
    }
});
