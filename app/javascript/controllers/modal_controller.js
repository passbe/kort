import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

	connect() {
		this.element.focus();
	}

	hide(event) {
		event.preventDefault();
		this.element.remove();
	}

	hideOnSubmit(event) {
		if (event.detail.success) {
			this.hide();
		}
	}

	disconnect() {
		this.modalTurboFrame.src = null;
	}

	modalTurboFrame() {
		return document.querySelector("turbo-frame[id='modal']");
	}
}
