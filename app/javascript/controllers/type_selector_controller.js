import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

	static targets = [
		'option'
	]

	static values = {
		modal: String
	}

	update(event) {
		const frame = this.targetTurboFrame();
		this.optionTargets.forEach((option, index) => {
			if (option.value == event.target.value) {
				if (option.dataset.location) {
					frame.src = option.dataset.location;
					frame.reload();
				}
			}
		});
	}

	targetTurboFrame() {
		return document.querySelector("turbo-frame[id='"+this.modalValue+"']");
	}
}
