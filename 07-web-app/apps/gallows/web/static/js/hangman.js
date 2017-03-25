import {Socket} from "phoenix"
import $        from "jquery"

import Gallows  from "./gallows"

export default class Hangman {

    constructor() {
        this.setupDOM()
        this.channel = this.join_channel();
        this.setupEventHandlers(this.channel)
        this.gallows = new Gallows()
        this.channel.push("get_status", {})
    }

    setupDOM() {
        this.letters      = $(".letter")
        this.guesses_left = $("#guesses-left")
        this.word_so_far  = $("#word-so-far")
        this.again        = $(".play-again")
    }

    join_channel() {
        let socket = new Socket("/socket", { logger: Hangman.my_logger })
        socket.connect()
        let channel = socket.channel("hangman:game")
        channel.join()
        return channel
    }

    setupEventHandlers(channel) {
        channel.on("status",     msg  =>  this.update_status(msg))
        this.again.on("click",   (ev) =>  this.play_again(ev))
        this.letters.on("click", (ev) =>  this.handle_click_on_letter(ev))
        $(document).on("keyup",      (ev) =>  this.handle_keypress(ev))
    }

    handle_keypress(event) {
        let letter = event.key
        if (letter >= "a" && letter <= "z") {
            let button = $(`#letter-${letter}`)
            if (!button.hasClass("guessed")) {
                button.addClass("guessed")
                this.channel.push("guess", { letter: letter })
            }
            event.preventDefault();
        }
    }

    handle_click_on_letter(event) {
        let letter = event.target
        $(letter).addClass("guessed")
        event.preventDefault();
        this.channel.push("guess", { letter: letter.text })
    }


    update_status(msg) {
        this.guesses_left.text("" + msg.turns_left)
        this.word_so_far.text(msg.letters.join(""))

        $(`#letter-${msg.last_guess}`).addClass(msg.guess_state)

        this.gallows.display_for(msg.turns_left)

        if (msg.game_state != "in_progress") { // get here if we have either won or lost
            this.letters.addClass("done")

            if (msg.game_state == "won") {
                this.gallows.display_win()
            }
            else {
                this.gallows.display_loss()
            }

        }
    }

    play_again(ev) {
        this.letters.removeClass("done guessed bad-guess good-guess")
        this.gallows.reset()
        this.channel.push("reset_game", {})
    }

    static my_logger(kind, msg, data) {
        console.log(`Socket: ${kind}: ${msg}`, data)
    }
}


