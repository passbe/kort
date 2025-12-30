import { Controller } from "@hotwired/stimulus"
import { useDebounce } from "stimulus-use"

export default class extends Controller {

	static targets = [
		"createForm",
		"validateForm",
		"expression",
		"grace",
		"expressionHidden",
		"graceHidden",
		"schedule"
	]

	static debounces = [{
		name: 'validate',
		wait: 500
	}]

	initialize() {
		this.validate = this.validate.bind(this);
	}

	connect() {
		useDebounce(this);
		this.caretPosition = 0;
		this.inputSelected = "";
	}

	expressionTargetConnected(element) { this.setCaretPosition(element) }
	graceTargetConnected(element) { this.setCaretPosition(element) }

	// Setup position of caret
	setCaretPosition(element) {
		if (this.inputSelected == element.name && element.value) {
			element.setSelectionRange(this.caretPosition, this.caretPosition)
		}
	}

	// Store position of caret
	storeCaretPosition(element) {
		this.caretPosition = element.selectionStart;
		this.inputSelected = element.name;
	}

	// Submit validate form
	validate(element) {
		this.storeCaretPosition(element.target);
		this.validateFormTarget.requestSubmit();
	}

	// Submit create form and let turbo do the rest
	submit(element) {
		this.expressionHiddenTarget.value = this.expressionTarget.value;
		this.expressionTarget.value = "";
		if (this.hasGraceTarget) {
			this.graceHiddenTarget.value = this.graceTarget.value;
			this.graceTarget.value = "";
		}
		this.createFormTarget.requestSubmit();
		this.validateFormTarget.requestSubmit();
	}

	// When we hit remove on a sub model - if its already created we need to set __destroy==1, otherwise remove the HTML
	remove(event) {
		// Find container in relation to remove button
		const container = event.target.closest('[data-schedule-target="schedule"]');
		if (container) {
			// Find id hidden field to check for new or existing record
			const idField = container.querySelector('input[type="hidden"][id$="_id"]');
			const destroyField = container.querySelector('input[type="hidden"][id$="__destroy"]');
			if (idField && destroyField) {
				// If not blank
				if (idField.value) {
					destroyField.value = "1";
					container.classList.add('hidden');
				} else {
					container.remove();
				}
			}
		}
	}

}
