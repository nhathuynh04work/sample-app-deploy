import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	// This method runs whenever the change event triggers
	validateSize() {
		const file = this.element.files[0];
		if (file) {
			const sizeInMB = file.size / 1024 / 1024;

			if (sizeInMB > 5) {
				alert(
					"Maximum file size is 5MB. Please choose a smaller file."
				);
				this.element.value = ""; // Clear the input
			}
		}
	}
}
