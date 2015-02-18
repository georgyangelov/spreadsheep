var AlignmentPicker = React.createClass({
    getDefaultProps: function() {
        return {
            onChange: function(alignment) { },
            initialAlignment: 'top_left',
            alignments: {
                top_left:      'fa-align-left',
                top_center:    'fa-align-center',
                top_right:     'fa-align-right',
                middle_left:   'fa-align-left',
                middle_center: 'fa-align-center',
                middle_right:  'fa-align-right',
                bottom_left:   'fa-align-left',
                bottom_center: 'fa-align-center',
                bottom_right:  'fa-align-right'
            }
        };
    },

    getInitialState: function() {
        return {alignment: this.props.initialAlignment};
    },

    render: function() {
        return (
            <div className="alignment-picker">
                <button onClick={this.toggleAlignmentBox} className={this.state.alignment}>
                    <i className={'align-icon fa ' + this.props.alignments[this.state.alignment] + ' ' + this.state.alignment}></i>
                </button>
                {this.state.alignmentBoxVisible ? this.renderAlignmentBox() : ''}
            </div>
        );
    },

    renderAlignmentBox: function() {
        return (
            <ul className="alignment-box">
                {_.map(this.props.alignments, this.renderAlignment)}
            </ul>
        );
    },

    renderAlignment: function(iconClass, alignment) {
        return (
            <li className={'alignment ' + alignment}
                onClick={this.selectAlignment.bind(this, alignment)}
            ><i className={'align-icon fa ' + iconClass + ' ' + alignment}></i></li>
        );
    },

    selectAlignment: function(alignment) {
        this.setState({
            alignment: alignment,
            alignmentBoxVisible: false
        });

        this.props.onChange(alignment);
    },

    setSelectedAlignment: function(alignment) {
        this.setState({
            alignment: alignment
        });
    },

    toggleAlignmentBox: function() {
        this.setState({
            alignmentBoxVisible: !this.state.alignmentBoxVisible
        });
    }
});
