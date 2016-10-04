const React = require('react')
const ReactDOM = require('react-dom')

import socket from "./socket"
// import moment from "moment"
const moment = require('moment')

// Now that you are connected, you can join channels with a topic:
var channel = null

class Room extends React.Component {
    constructor(props){
        super(props)
        this.state = {
            messages: [],
        }

        channel.on("new_msg", payload => {
            this.appendMessage(payload)
        })
    }

    appendMessage(message) {
        this.setState({messages: this.state.messages.concat(message)})
    }

    render() {
        return (
            <ul className="list-unstyled">
                {this.state.messages.map((message, i) => {
                    let date = moment(message.timestamp)
                    return (
                        <li key={i}><strong>{message.user_name}:</strong> { message.body } <span className="pull-xs-right small">{ date.format("HH:MM:ss.SSS") }</span></li>
                    )
                })}
            </ul>
        );
    }
}

class MessageForm extends React.Component {
    constructor(props){
        super(props)
        this.state = {
            textValue: "",
            editingUsers: new Set(),
        }

        channel.on("editing", payload => {
            this.insertEditingUser(payload)
        })

        channel.on("end_editing", payload => {
            this.removeEditingUser(payload)
        })
    }

    componentDidMount() {
        this.timer = setInterval(this.pushEditingState.bind(this), 500);
    }

    componentWillUnmount() {
        clearInterval(this.timer);
    }

    pushEditingState() {
        if (this.state.textValue.match(/^\s*$/)) {
            channel.push("end_editing", {})
        } else {
            channel.push("editing", {})
        }
    }

    changeText(event) {
        this.setState(Object.assign(this.state, {textValue: event.target.value}))
        this.pushEditingState()
    }

    sendMessage(event) {
        event.preventDefault()
        if (this.state.textValue.match(/^\s*$/)) return
        channel.push("new_msg", {body: this.state.textValue})
        this.setState(Object.assign(this.state, {textValue: ""}))
    }

    insertEditingUser(payload) {
        if(payload.user_name == channel.params.name) return
        var users = this.state.editingUsers
        users.add(payload.user_name)
        this.setState(Object.assign(this.state, {editingUsers: users}))
    }

    removeEditingUser(payload) {
        var users = this.state.editingUsers
        users.delete(payload.user_name)
        this.setState(Object.assign(this.state, {editingUsers: users}))
    }

    editingUsers() {
        if (1 == this.state.editingUsers.size) {
            return `${Array.from(this.state.editingUsers)[0]} is editing...`
        }
        else if (1 < this.state.editingUsers.size) {
            return `${Array.from(this.state.editingUsers).join(', ')} are editing...`
        } else {
            return null
        }
    }

    render() {
        return (
            <form className="" onSubmit={this.sendMessage.bind(this)}>
              <div className="form-group">
                <div className="input-group">
                    <input id="message-input" className="form-control" type='text' placeholder='Input some message' value={this.state.textValue} onChange={this.changeText.bind(this)} />
                    <span className="input-group-btn">
                        <button className="btn btn-primary">Send</button>
                    </span>
                </div>
                <small>{ this.editingUsers() }</small>
              </div>
            </form>
        );
    }
}

class UserNameForm extends React.Component {
    constructor(props){
        super(props)
        this.state = {
            textValue: "",
        }
    }

    componentDidMount() {
        // document.getElementById('username-input').focus()
    }

    changeText(event) {
        this.setState({textValue: event.target.value})
    }

    joinRoom(event) {
        event.preventDefault()
        channel = socket.channel(`room:${window.roomUUID}`, {name: this.state.textValue})
        channel.join()
            .receive("ok", resp => {
                hideUsernameForm()
                showChatRoom()
            })
            .receive("error", resp => {
                alert("Unable to join the room. Please retry.")
            })
    }

    render() {
        return (
            <form className="" onSubmit={this.joinRoom.bind(this)}>
              <div className="form-group">
                <div className="input-group">
                    <input id="username-input" className="form-control" type='text' placeholder='Your name' value={this.state.textValue} onChange={this.changeText.bind(this)} />
                    <span className="input-group-btn">
                        <button className="btn btn-primary">Join</button>
                    </span>
                </div>
              </div>
            </form>
        );
    }
}

let usernameInputForm = document.getElementById('username-input')

ReactDOM.render(
    <UserNameForm  />,
    usernameInputForm,
);

const hideUsernameForm = () => {
    let usernameInputForm = document.getElementById('username-input')
    usernameInputForm.style.display = 'none'
}

const showChatRoom = () => {
    let messagesElement = document.getElementById('messages')
    if (messagesElement) {
        ReactDOM.render(
            <Room />,
            messagesElement
        );

        ReactDOM.render(
            <MessageForm  />,
            document.getElementById('message-input'),
        );
    }
}

window.onload = () => {
    document.body.style.minHeight = window.innerHeight
}
