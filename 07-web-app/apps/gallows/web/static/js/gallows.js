import $        from "jquery"

export default class Gallows {

    constructor() {
        this.Snap = window.Snap
        this.drawing = Snap('#drawing')
        this.setup_parts()
        this.reset()
    }

    setup_parts() {
        this.person = [
            "#leg2",
            "#leg1",
            "#arm2",
            "#arm1",
            "#body",
            "#head",
        ]
        this.gallows = [
            "#rope",
            "#brace",
            "#topbar",
            "#post",
            "#ground",
        ]

        this.parts = this.person.concat(this.gallows)
    }

    display_for(turns_left) {
        if (turns_left > this.turns_left) {
            for (let i = this.turns_left; i < turns_left; i++) {
                this.remove_element(this.parts[i])
            }
        }
        else if (turns_left < this.turns_left) {
            for (let i = this.turns_left-1; i >= turns_left; i--) {
                this.add_element(this.parts[i])
            }
        }
        this.turns_left = turns_left
    }

    display_win() {
        for (let part of this.gallows) {
            this.remove_element(part)
        }
        for (let part of this.person) {
            this.add_element(part)
        }
        $(".gallows").addClass("result")
        $(".won").fadeIn({duration: 1000})
    }

    display_loss() {
        $(".gallows").addClass("result")
        $(".lost").fadeIn({duration: 1000})
    }

    reset() {
        for (let i = 0; i < 11; i++) {
            this.remove_element(this.parts[i])
        }
        this.turns_left = 11
        $(".you").hide()
        $(".gallows").removeClass("result")
    }


    remove_element(name) {
        console.dir(name)
        let svg_element = this.drawing.select(name)
        svg_element.animate({stroke: "white", fill: "white"}, 300)
    }

    add_element(name) {
        let $element = $(name)
        let svg_element = this.drawing.select(name)
        let color = $element.data("color") || "#777"

        if ($element.data("just-stroke")) {
            this.add_stroke(svg_element, color)
        }
        else {
            this.add_both(svg_element, color)
        }
    }

    add_stroke(element, color) {
        element
            .animate({stroke: "#888"}, 200, function() {
                element.animate({stroke: color}, 150)})
    }

    add_both(element, color) {
        element.animate({stroke: "888", fill: "#888"}, 200, function() {
            element.animate({stroke: color, fill: color}, 100)})
    }
    
}
