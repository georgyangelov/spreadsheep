var FontSizePicker = React.createClass({
    getDefaultProps: function() {
        return {
            onChange: function(fontSize) { },
            initialSize: 16,
            fontSizes: [10, 12, 14, 16, 17, 18, 19, 20, 22, 24, 26, 28, 30, 32]
        };
    },

    getInitialState: function() {
        return {fontSize: this.props.initialSize};
    },

    render: function() {
        return (
            <div className="font-size-picker">
                <button onClick={this.toggleFontSizeBox}>{this.state.fontSize}px</button>
                {this.state.fontSizeBoxVisible ? this.renderFontSizeBox() : ''}
            </div>
        );
    },

    renderFontSizeBox: function() {
        return (
            <ul className="font-size-box">
                {this.props.fontSizes.map(this.renderFontSize)}
            </ul>
        );
    },

    renderFontSize: function(fontSize) {
        var style = {
            fontSize: fontSize + 'px'
        };

        return (
            <li className="font-size"
                style={style}
                onClick={this.selectFontSize.bind(this, fontSize)}
            >{fontSize}px</li>
        );
    },

    selectFontSize: function(fontSize) {
        this.setState({
            fontSize: fontSize,
            fontSizeBoxVisible: false
        });

        this.props.onChange(fontSize);
    },

    setSelectedFontSize: function(fontSize) {
        this.setState({
            fontSize: fontSize
        });
    },

    toggleFontSizeBox: function() {
        this.setState({
            fontSizeBoxVisible: !this.state.fontSizeBoxVisible
        });
    }
});
