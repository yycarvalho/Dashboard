/**
 * Gerenciador de Interface do Usuário
 * Responsável por componentes visuais, modais, toasts, loading, etc.
 */
(function() {
	class UIManager {
		constructor() {
			this.toastContainer = document.getElementById('toastContainer');
			this.modalContainer = document.getElementById('modalContainer');
			this.loadingOverlay = document.getElementById('loading');
			this.activeModal = null;
		}

		// Toasts
		showToast(message, type = 'success', timeout = CONFIG.TIMEOUTS.TOAST) {
			if (!this.toastContainer) return;
			const toast = document.createElement('div');
			toast.className = `toast ${type}`;
			toast.setAttribute('role', 'status');
			toast.setAttribute('aria-live', 'polite');
			toast.textContent = message;
			this.toastContainer.appendChild(toast);
			setTimeout(() => {
				toast.style.opacity = '0';
				setTimeout(() => toast.remove(), 300);
			}, timeout);
		}

		// Loading
		showLoading() {
			if (this.loadingOverlay) {
				this.loadingOverlay.classList.remove('hidden');
			}
		}

		hideLoading() {
			if (this.loadingOverlay) {
				this.loadingOverlay.classList.add('hidden');
			}
		}

		// Modal
		showModal({ title = '', content = '', footer = null, size = 'md' } = {}) {
			if (!this.modalContainer) return;

			// Cleanup previous
			this.closeModal();

			const backdrop = document.createElement('div');
			backdrop.className = 'modal-backdrop';
			backdrop.addEventListener('click', (e) => {
				if (e.target === backdrop) this.closeModal();
			});

			const modal = document.createElement('div');
			modal.className = 'modal-content';
			modal.setAttribute('role', 'dialog');
			modal.setAttribute('aria-modal', 'true');
			modal.setAttribute('aria-labelledby', 'modalTitle');

			const header = document.createElement('div');
			header.className = 'modal-header';
			const h3 = document.createElement('h3');
			h3.id = 'modalTitle';
			h3.textContent = title;
			const closeBtn = document.createElement('button');
			closeBtn.className = 'modal-close';
			closeBtn.setAttribute('aria-label', 'Fechar');
			closeBtn.innerHTML = '&times;';
			closeBtn.addEventListener('click', () => this.closeModal());
			header.appendChild(h3);
			header.appendChild(closeBtn);

			const body = document.createElement('div');
			body.className = 'modal-body';
			if (typeof content === 'string') {
				body.innerHTML = content;
			} else if (content instanceof Node) {
				body.appendChild(content);
			}

			modal.appendChild(header);
			modal.appendChild(body);

			if (footer) {
				const footerEl = document.createElement('div');
				footerEl.className = 'modal-footer';
				if (typeof footer === 'string') {
					footerEl.innerHTML = footer;
				} else if (footer instanceof Node) {
					footerEl.appendChild(footer);
				}
				modal.appendChild(footerEl);
			}

			backdrop.appendChild(modal);
			this.modalContainer.appendChild(backdrop);
			this.activeModal = backdrop;

			// Focus trap: focus close button initially
			closeBtn.focus();

			// Keyboard handlers
			document.addEventListener('keydown', this._escHandler);
		}

		_escHandler = (e) => {
			if (e.key === 'Escape') {
				this.closeModal();
			}
		};

		closeModal() {
			if (this.activeModal) {
				this.activeModal.remove();
				this.activeModal = null;
				document.removeEventListener('keydown', this._escHandler);
			}
		}

		// Simple form builder for modals
		createForm(fields = [], { submitText = 'Salvar', onSubmit = null, onCancel = null } = {}) {
			const form = document.createElement('form');
			form.setAttribute('novalidate', 'true');

			fields.forEach(field => {
				const group = document.createElement('div');
				group.className = 'form-group';

				const label = document.createElement('label');
				label.textContent = field.label || '';
				if (field.name) label.setAttribute('for', field.name);
				group.appendChild(label);

				let input;
				switch (field.type) {
					case 'textarea':
						input = document.createElement('textarea');
						break;
					case 'select':
						input = document.createElement('select');
						(field.options || []).forEach(opt => {
							const option = document.createElement('option');
							option.value = String(opt.value);
							option.textContent = opt.label;
							input.appendChild(option);
						});
						break;
					default:
						input = document.createElement('input');
						input.type = field.type || 'text';
				}

				input.id = field.name;
				input.name = field.name;
				if (field.placeholder) input.placeholder = field.placeholder;
				if (field.required) input.required = true;
				if (field.value !== undefined && field.value !== null) input.value = String(field.value);

				group.appendChild(input);
				form.appendChild(group);
			});

			const footer = document.createElement('div');
			const cancelBtn = document.createElement('button');
			cancelBtn.type = 'button';
			cancelBtn.className = 'btn btn-secondary';
			cancelBtn.textContent = 'Cancelar';
			cancelBtn.addEventListener('click', () => {
				if (onCancel) onCancel();
			});
			const submitBtn = document.createElement('button');
			submitBtn.type = 'submit';
			submitBtn.className = 'btn btn-primary';
			submitBtn.textContent = submitText;
			footer.appendChild(cancelBtn);
			footer.appendChild(submitBtn);

			form.addEventListener('submit', async (e) => {
				e.preventDefault();
				const formData = new FormData(form);
				const data = {};
				for (const [key, value] of formData.entries()) {
					data[key] = value;
				}
				if (onSubmit) await onSubmit(data);
			});

			return { form, footer };
		}

		// Accessible confirmation dialog
		showConfirmation(message, { title = 'Confirmação', confirmText = 'Confirmar', type = 'warning' } = {}) {
			return new Promise((resolve) => {
				const content = document.createElement('div');
				content.innerHTML = `<p>${message}</p>`;

				const footer = document.createElement('div');
				const cancel = document.createElement('button');
				cancel.className = 'btn btn-secondary';
				cancel.textContent = 'Cancelar';
				cancel.addEventListener('click', () => { this.closeModal(); resolve(false); });
				const confirm = document.createElement('button');
				confirm.className = `btn ${type === 'danger' ? 'btn-danger' : type === 'success' ? 'btn-success' : 'btn-warning'}`;
				confirm.textContent = confirmText;
				confirm.addEventListener('click', () => { this.closeModal(); resolve(true); });
				footer.appendChild(cancel);
				footer.appendChild(confirm);

				this.showModal({ title, content, footer });
			});
		}

		// Form error helper
		showFieldError(fieldName, message) {
			this.showToast(message, 'error');
			const field = document.querySelector(`[name="${fieldName}"]`);
			if (field) {
				field.setAttribute('aria-invalid', 'true');
				field.focus({ preventScroll: true });
			}
		}
	}

	window.UI = new UIManager();
})();

