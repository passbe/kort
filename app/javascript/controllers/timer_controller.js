import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

	static values = {
		time: Number
	}

	connect(event) {
		this.interval = setInterval(this.update, 1000, this);
	}

	update(context) {
		const total = Math.abs(Math.floor(Date.now() / 1000) - context.timeValue);
		const hours = Math.floor(total / 3600);
		const remaining = total % 3600;
		const minutes = Math.floor(remaining / 60);
		const seconds = Math.floor(remaining % 60);
		var parts = [];
		if (hours > 0) {
			parts.push(hours+"h")
		}
		if (parts.length > 0 || minutes > 0) {
			parts.push(minutes+"m")
		}
		parts.push(seconds+"s")
		context.element.innerHTML = parts.join(" ")
	}

	disconnect() {
		clearInterval(this.interval);
	}

}
