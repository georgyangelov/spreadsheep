var UserList = React.createClass({
    getInitialState: function() {
        return {users: []};
    },

    render: function() {
        return (
            <ul className="user-list">
                {_.map(this.state.users, this.renderUser)}
            </ul>
        );
    },

    renderUser: function(user) {
        var style = {
            'background-color': user.color
        };

        return (
            <li title={user.name} style={style}>{this.getInitials(user.name)}</li>
        );
    },

    getInitials: function(name) {
        var names = name.split(' ');

        return names[0].substr(0, 1).toUpperCase() + names[1].substr(0, 1).toUpperCase();
    },

    add: function(id, name, color) {
        var user = {
            id: id,
            name: name,
            color: color
        };

        this.setState({
            users: this.state.users.concat([user])
        });
    },

    remove: function(id) {
        this.setState({
            users: _.reject(this.state.users, {id: id})
        });
    }
});
