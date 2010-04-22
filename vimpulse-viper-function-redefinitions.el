;;;; Redefinitions of some of Viper's functions

(defcustom vimpulse-want-change-state nil
  "Whether commands like \"cw\" invoke Replace state, vi-like.
The default is to delete the text and enter Insert state,
like in Vim."
  :group 'vimpulse
  :type  'boolean)

(defadvice viper-change
  (around vimpulse-want-change-state activate)
  "Disable Replace state if `vimpulse-want-change-state' is nil."
  (cond
   (vimpulse-want-change-state
    ad-do-it)
   (t
    ;; We don't want Viper's Replace mode when changing text;
    ;; just delete and enter Insert state
    (setq viper-began-as-replace t)
    (kill-region beg end)
    (viper-change-state-to-insert))))

;;; Code for adding extra states

;; State index variables: for keeping track of which modes
;; belong to which states, et cetera
(defvar vimpulse-state-vars-alist
  '((vi-state
     (id . viper-vi-state-id)
     (change-func . viper-change-state-to-vi)
     (basic-mode . viper-vi-basic-minor-mode)
     (basic-map . viper-vi-basic-map)
     (diehard-mode . viper-vi-diehard-minor-mode)
     (diehard-map . viper-vi-diehard-map)
     (modifier-mode . viper-vi-state-modifier-minor-mode)
     (modifier-alist . viper-vi-state-modifier-alist)
     (kbd-mode . viper-vi-kbd-minor-mode)
     (kbd-map . viper-vi-kbd-map)
     (global-user-mode . viper-vi-global-user-minor-mode)
     (global-user-map . viper-vi-global-user-map)
     (local-user-mode . viper-vi-local-user-minor-mode)
     (local-user-map . viper-vi-local-user-map)
     (need-local-map . viper-need-new-vi-local-map)
     (intercept-mode . viper-vi-intercept-minor-mode)
     (intercept-map . viper-vi-intercept-map))
    (insert-state
     (id . viper-insert-state-id)
     (change-func . viper-change-state-to-insert)
     (basic-mode . viper-insert-basic-minor-mode)
     (basic-map . viper-insert-basic-map)
     (diehard-mode . viper-insert-diehard-minor-mode)
     (diehard-map . viper-insert-diehard-map)
     (modifier-mode . viper-insert-state-modifier-minor-mode)
     (modifier-alist . viper-insert-state-modifier-alist)
     (kbd-mode . viper-insert-kbd-minor-mode)
     (kbd-map . viper-insert-kbd-map)
     (global-user-mode . viper-insert-global-user-minor-mode)
     (global-user-map . viper-insert-global-user-map)
     (local-user-mode . viper-insert-local-user-minor-mode)
     (local-user-map . viper-insert-local-user-map)
     (need-local-map . viper-need-new-insert-local-map)
     (intercept-mode . viper-insert-intercept-minor-mode)
     (intercept-map . viper-insert-intercept-map))
    (replace-state
     (id . viper-replace-state-id)
     (change-func . viper-change-state-to-replace)
     (basic-mode . viper-replace-minor-mode)
     (basic-map . viper-replace-map))
    (emacs-state
     (id . viper-emacs-state-id)
     (change-func . viper-change-state-to-emacs)
     (modifier-mode . viper-emacs-state-modifier-minor-mode)
     (modifier-alist . viper-emacs-state-modifier-alist)
     (kbd-mode . viper-emacs-kbd-minor-mode)
     (kbd-map . viper-emacs-kbd-map)
     (global-user-mode . viper-emacs-global-user-minor-mode)
     (global-user-map . viper-emacs-global-user-map)
     (local-user-mode . viper-emacs-local-user-minor-mode)
     (local-user-map . viper-emacs-local-user-map)
     (need-local-map . viper-need-new-emacs-local-map)
     (intercept-mode . viper-emacs-intercept-minor-mode)
     (intercept-map . viper-emacs-intercept-map)))
  "Alist of Vimpulse state variables.
Entries have the form (STATE . ((VAR-TYPE . VAR) ...)).
For example, the basic state keymap has the VAR-TYPE `basic-map'.")

(defvar vimpulse-state-modes-alist
  '((vi-state
     (viper-vi-intercept-minor-mode . t)
     (viper-vi-minibuffer-minor-mode . (viper-is-in-minibuffer))
     (viper-vi-local-user-minor-mode . t)
     (viper-vi-global-user-minor-mode . t)
     (viper-vi-kbd-minor-mode . (not (viper-is-in-minibuffer)))
     (viper-vi-state-modifier-minor-mode . t)
     (viper-vi-diehard-minor-mode
      . (not (or viper-want-emacs-keys-in-vi
                 (viper-is-in-minibuffer))))
     (viper-vi-basic-minor-mode . t))
    (insert-state
     (viper-insert-intercept-minor-mode . t)
     (viper-replace-minor-mode . (eq state 'replace-state))
     (viper-insert-minibuffer-minor-mode . (viper-is-in-minibuffer))
     (viper-insert-local-user-minor-mode . t)
     (viper-insert-global-user-minor-mode . t)
     (viper-insert-kbd-minor-mode . (not (viper-is-in-minibuffer)))
     (viper-insert-state-modifier-minor-mode . t)
     (viper-insert-diehard-minor-mode
      . (not (or viper-want-emacs-keys-in-insert
                 (viper-is-in-minibuffer))))
     (viper-insert-basic-minor-mode . t))
    (replace-state
     (viper-insert-intercept-minor-mode . t)
     (viper-replace-minor-mode . (eq state 'replace-state))
     (viper-insert-minibuffer-minor-mode . (viper-is-in-minibuffer))
     (viper-insert-local-user-minor-mode . t)
     (viper-insert-global-user-minor-mode . t)
     (viper-insert-kbd-minor-mode . (not (viper-is-in-minibuffer)))
     (viper-insert-state-modifier-minor-mode . t)
     (viper-insert-diehard-minor-mode
      . (not (or viper-want-emacs-keys-in-insert
                 (viper-is-in-minibuffer))))
     (viper-insert-basic-minor-mode . t))
    (emacs-state
     (viper-emacs-intercept-minor-mode . t)
     (viper-emacs-local-user-minor-mode . t)
     (viper-emacs-global-user-minor-mode . t)
     (viper-emacs-kbd-minor-mode . (not (viper-is-in-minibuffer)))
     (viper-emacs-state-modifier-minor-mode . t)))
  "Alist of Vimpulse state mode toggling.
Entries have the form (STATE . ((MODE . EXPR) ...)), where STATE
is the name of a state, MODE is a mode associated with STATE and
EXPR is an expression with which to enable or disable MODE.
The first modes get the highest priority.")

(defvar vimpulse-state-maps-alist nil
  "Alist of Vimpulse modes and keymaps.
Entries have the form (MODE . MAP-EXPR), where MAP-EXPR is an
expression for determining the keymap of MODE.")

;; State-changing code: this uses the variables above
(defadvice viper-normalize-minor-mode-map-alist
  (after vimpulse-states activate)
  "Normalize Vimpulse state maps."
  (let (temp mode map alists toggle toggle-alist)
    ;; Determine which of `viper--key-maps' and
    ;; `minor-mode-map-alist' to normalize
    (cond
     ((featurep 'xemacs)
      (setq alists '(viper--key-maps minor-mode-map-alist)))
     ((>= emacs-major-version 22)
      (setq alists '(viper--key-maps)))
     (t
      (setq alists '(minor-mode-map-alist))))
    ;; Normalize the modes in the order
    ;; they are toggled by the current state
    (dolist (entry (reverse (cdr (assq viper-current-state
                                       vimpulse-state-modes-alist))))
      (setq mode (car entry)
            map (eval (cdr (assq mode vimpulse-state-maps-alist))))
      (when map
        (dolist (alist alists)
          (setq temp (default-value alist))
          (setq temp (assq-delete-all mode temp)) ; already there?
          (add-to-list 'temp (cons mode map))
          (set-default alist temp)
          (setq temp (eval alist))
          (setq temp (assq-delete-all mode temp))
          (add-to-list 'temp (cons mode map))
          (set alist temp))))))

(defadvice viper-refresh-mode-line (after vimpulse-states activate)
  "Refresh mode line tag for Vimpulse states."
  (let ((id (assq viper-current-state vimpulse-state-vars-alist)))
    (setq id (eval (cdr (assq 'id (cdr id)))))
    (when id
      (set (make-local-variable 'viper-mode-string) id)
      (force-mode-line-update))))

(defadvice viper-set-mode-vars-for (after vimpulse-states activate)
  "Toggle Vimpulse state modes."
  (let (enable disable)
    ;; Determine which modes to enable
    (setq enable (cdr (assq state vimpulse-state-modes-alist)))
    (when enable
      ;; Determine which modes to disable
      (dolist (entry vimpulse-state-modes-alist)
        (dolist (mode (mapcar 'car (cdr entry)))
          (unless (assq mode enable)
            (add-to-list 'disable mode t))))
      ;; Enable modes
      (dolist (entry enable)
        (when (boundp (car entry))
          (set (car entry) (eval (cdr entry)))))
      ;; Disable modes
      (dolist (entry disable)
        (when (boundp entry)
          (set entry nil))))))

(defadvice viper-change-state (before vimpulse-states activate)
  "Update `viper-insert-point'."
  (let (mark-active)
    (unless (mark t)
      (push-mark nil t nil)))
  (when (and (eq 'insert-state new-state)
             (not (memq viper-current-state '(vi-state emacs-state))))
    (viper-move-marker-locally 'viper-insert-point (point))))

(defun vimpulse-modifier-map (state &optional mode)
  "Return the current major mode modifier map for STATE.
If none, return an empty keymap (`viper-empty-keymap')."
  (setq mode (or mode major-mode))
  (setq state (assq state vimpulse-state-vars-alist))
  (setq state (eval (cdr (assq 'modifier-alist (cdr state)))))
  (if (keymapp (cdr (assoc mode state)))
      (cdr (assoc mode state))
    viper-empty-keymap))

(defun vimpulse-modify-major-mode (mode state keymap)
  "Modify key bindings in a major-mode in a Viper state using a keymap.

If the default for a major mode is emacs-state, then
modifications to this major mode may not take effect until the
buffer switches state to Vi, Insert or Emacs. If this happens,
add `viper-change-state-to-emacs' to this major mode's hook.
If no such hook exists, you may have to put an advice on the
function that invokes the major mode. See `viper-set-hooks'
for hints.

The above needs not to be done for major modes that come up in
Vi or Insert state by default."
  (let (alist elt)
    (setq alist (cdr (assq state vimpulse-state-vars-alist)))
    (setq alist (cdr (assq 'modifier-alist alist)))
    (if (setq elt (assoc mode (eval alist)))
        (set alist (delq elt (eval alist))))
    (set alist (cons (cons mode keymap) (eval alist)))
    (viper-normalize-minor-mode-map-alist)
    (viper-set-mode-vars-for viper-current-state)))

(fset 'viper-modify-major-mode 'vimpulse-modify-major-mode)

(defun vimpulse-add-local-keys (state alist)
  "Override some vi-state or insert-state bindings in the current buffer.
The effect is seen in the current buffer only.
Useful for customizing  mailer buffers, gnus, etc.
STATE is 'vi-state, 'insert-state, or 'emacs-state
ALIST is of the form ((key . func) (key . func) ...)
Normally, this would be called from a hook to a major mode or
on a per buffer basis.
Usage:
      (viper-add-local-keys state '((key-str . func) (key-str . func)...))"
  (let (local-user-map need-local-user-map)
    (setq local-user-map (cdr (assq state vimpulse-state-vars-alist)))
    (when local-user-map
      (setq need-local-user-map
            (cdr (assq 'need-local-user-map local-user-map)))
      (setq local-user-map
            (cdr (assq 'local-user-map local-user-map)))
      (when (eval need-local-user-map)
        (set local-user-map (make-sparse-keymap))
        (set need-local-user-map nil))
      (viper-modify-keymap (eval local-user-map) alist)
      (viper-normalize-minor-mode-map-alist)
      (viper-set-mode-vars-for viper-current-state))))

(fset 'viper-add-local-keys 'vimpulse-add-local-keys)

;; Macro for defining new Viper states. This saves us the trouble of
;; defining and indexing all those minor modes manually.
(defmacro vimpulse-define-state (state doc &rest body)
  "Define a new Viper state STATE.
DOC is a general description and shows up in all docstrings.
Then follows one or more optional keywords:

:id ID                  Mode line indicator.
:hook LIST              Hooks run before changing to STATE.
:change-func FUNC       Function to change to STATE.
:basic-mode MODE        Basic minor mode for STATE.
:basic-map MAP          Keymap of :basic-mode.
:diehard-mode MODE      Minor mode for when Viper want to be vi.
:diehard-map MAP        Keymap of :diehard-mode.
:modifier-mode MODE     Minor mode for modifying major modes.
:modifier-alist LIST    Keymap alist for :modifier-mode.
:kbd-mode MODE          Minor mode for Ex command macros.
:kbd-map MAP            Keymap of :kbd-mode.
:global-user-mode MODE  Minor mode for global user bindings.
:global-user-map MAP    Keymap of :global-user-mode.
:local-user-mode MODE   Minor mode for local user bindings.
:local-user-map MAP     Keymap of :local-user-mode.
:need-local-map VAR     Buffer-local variable for :local-user-mode.
:intercept-mode         Minor mode for vital Viper bindings.
:intercept-map          Keymap of :intercept-mode.
:enable LIST            List of other modes enabled by STATE.
:prefix PREFIX          Variable prefix, default \"vimpulse-\".
:advice TYPE            Toggle advice type, default `after'.

It is not necessary to specify all of these; the minor modes are
created automatically unless you provide an existing mode. The
only keyword you should really specify is :id, the mode line tag.
For example:

    (vimpulse-define-state test
      \"A simple test state.\"
      :id \"<T> \")

The basic keymap of this state will then be
`vimpulse-test-basic-map', and so on.

Following the keywords is optional code to be executed each time
the state is enabled or disabled. This is stored in a `defadvice'
of `viper-change-state'. :advice specifies the advice type
\(default `after'). The advice runs :hook before completing."
  (declare (debug (&define name stringp
                           [&rest [keywordp sexp]]
                           def-body))
           (indent defun))
  (let (advice basic-map basic-mode change change-func diehard-map
               diehard-mode enable enable-modes-alist enable-states-alist
               global-user-map global-user-mode hook id id-string
               intercept-map intercept-mode kbd-map kbd-mode keyword
               local-user-map local-user-mode modes-alist modifier-alist
               modifier-mode name name-string need-local-map prefix
               prefixed-name-string state-name state-name-string vars-alist)
    ;; Collect keywords
    (while (keywordp (setq keyword (car body)))
      (setq body (cdr body))
      (cond
       ((eq :prefix keyword)
        (setq prefix (vimpulse-unquote (pop body))))
       ((eq :enable keyword)
        (setq enable (vimpulse-unquote (pop body))))
       ((eq :advice keyword)
        (setq advice (vimpulse-unquote (pop body))))
       ((memq keyword '(:state-id :id))
        (setq id (vimpulse-unquote (pop body))))
       ((memq keyword '(:state-hook :hook))
        (setq hook (vimpulse-unquote (pop body))))
       ((memq keyword '(:change-func :change))
        (setq change-func (vimpulse-unquote (pop body))))
       ((memq keyword '(:basic-mode :basic-minor-mode))
        (setq basic-mode (vimpulse-unquote (pop body))))
       ((eq :basic-map keyword)
        (setq basic-map (vimpulse-unquote (pop body))))
       ((memq keyword '(:local-user-mode
                        :local-mode
                        :local-user-minor-mode))
        (setq local-user-mode (vimpulse-unquote (pop body))))
       ((memq keyword '(:local-user-map :local-map))
        (setq local-user-map (vimpulse-unquote (pop body))))
       ((memq keyword '(:need-new-local-map
                        :need-local-map
                        :need-map))
        (setq need-local-map (vimpulse-unquote (pop body))))
       ((memq keyword '(:global-user-mode
                        :global-mode
                        :global-user-minor-mode))
        (setq global-user-mode (vimpulse-unquote (pop body))))
       ((memq keyword '(:global-user-map :global-map))
        (setq global-user-map (vimpulse-unquote (pop body))))
       ((memq keyword '(:state-modifier-minor-mode
                        :state-modifier-mode
                        :modifier-minor-mode
                        :modifier-mode))
        (setq modifier-mode (vimpulse-unquote (pop body))))
       ((memq keyword '(:state-modifier-alist :modifier-alist))
        (setq modifier-alist (vimpulse-unquote (pop body))))
       ((memq keyword '(:diehard-mode :diehard-minor-mode))
        (setq diehard-mode (vimpulse-unquote (pop body))))
       ((eq :diehard-map keyword)
        (setq diehard-map (vimpulse-unquote (pop body))))
       ((memq keyword '(:kbd-mode :kbd-minor-mode))
        (setq kbd-mode (vimpulse-unquote (pop body))))
       ((eq :kbd-map keyword)
        (setq kbd-map (vimpulse-unquote (pop body))))
       ((memq keyword '(:intercept-mode :intercept-minor-mode))
        (setq intercept-mode (vimpulse-unquote (pop body))))
       ((eq :intercept-map keyword)
        (setq intercept-map (vimpulse-unquote (pop body))))
       (t
        (pop body))))
    ;; Set up the state name
    (setq name-string (replace-regexp-in-string
                       "-state$" "" (symbol-name state)))
    (setq name (intern name-string))
    (setq state-name-string (concat name-string "-state"))
    (setq state-name (intern state-name-string))
    (when (and prefix (symbolp prefix))
      (setq prefix (symbol-name prefix)))
    (setq prefix (or prefix "vimpulse-"))
    (setq prefix (concat (replace-regexp-in-string
                          "-$" "" prefix) "-"))
    (setq prefixed-name-string (concat prefix name-string))
    ;; Create state variables
    (setq id
          (vimpulse-define-symbol
           id (concat prefixed-name-string "-state-id")
           (format "<%s> " (upcase name-string)) 'stringp
           (format "Mode line tag indicating %s.\n\n%s"
                   state-name doc)))
    (setq hook
          (vimpulse-define-symbol
           hook (concat prefixed-name-string "-state-hook")
           nil 'listp (format "*Hooks run just before the switch to %s \
is completed.\n\n%s" state-name doc)))
    (setq basic-mode
          (vimpulse-define-symbol
           basic-mode
           (concat prefixed-name-string "-basic-minor-mode")
           nil nil (format "Basic minor mode for %s.\n\n%s"
                           state-name doc) t))
    (setq basic-map
          (vimpulse-define-symbol
           basic-map (concat prefixed-name-string "-basic-map")
           (make-sparse-keymap) 'keymapp
           (format "The basic %s keymap.\n\n%s" state-name doc)))
    (setq diehard-mode
          (vimpulse-define-symbol
           diehard-mode
           (concat prefixed-name-string "-diehard-minor-mode")
           nil nil (format "This minor mode is in effect when \
the user wants Viper to be vi.\n\n%s" doc) t))
    (setq diehard-map
          (vimpulse-define-symbol
           diehard-map
           (concat prefixed-name-string "-diehard-map")
           (make-sparse-keymap) 'keymapp
           (format "This keymap is in use when the user asks \
Viper to simulate vi very closely.
This happens when `viper-expert-level' is 1 or 2.  \
See `viper-set-expert-level'.\n\n%s" doc)))
    (setq modifier-mode
          (vimpulse-define-symbol
           modifier-mode
           (concat prefixed-name-string "-state-modifier-minor-mode")
           nil nil (format "Minor mode used to make major \
mode-specific modifications to %s.\n\n%s" state-name doc) t))
    (setq modifier-alist
          (vimpulse-define-symbol
           modifier-alist
           (concat prefixed-name-string "-state-modifier-alist")
           nil 'listp))
    (setq kbd-mode
          (vimpulse-define-symbol
           kbd-mode
           (concat prefixed-name-string "-kbd-minor-mode")
           nil nil
           (format "Minor mode for Ex command macros in Vi state.
The corresponding keymap stores key bindings of Vi macros defined with
the Ex command :map.\n\n%s" doc) t))
    (setq kbd-map
          (vimpulse-define-symbol
           kbd-map
           (concat prefixed-name-string "-kbd-map")
           (make-sparse-keymap) 'keymapp
           (format "This keymap keeps keyboard macros defined \
via the :map command.\n\n%s" doc)))
    (setq global-user-mode
          (vimpulse-define-symbol
           global-user-mode
           (concat prefixed-name-string "-global-user-minor-mode")
           nil nil (format "Auxiliary minor mode for global \
user-defined bindings in %s.\n\n%s" state-name doc) t))
    (setq global-user-map
          (vimpulse-define-symbol
           global-user-map
           (concat prefixed-name-string "-global-user-map")
           (make-sparse-keymap) 'keymapp
           (format "Auxiliary map for global user-defined keybindings \
in %s.\n\n%s" state-name doc)))
    (setq local-user-mode
          (vimpulse-define-symbol
           local-user-mode
           (concat prefixed-name-string "-local-user-minor-mode")
           nil nil (format "Auxiliary minor mode for user-defined \
local bindings in %s.\n\n%s" state-name doc) t))
    (setq local-user-map
          (vimpulse-define-symbol
           local-user-map
           (concat prefixed-name-string "-local-user-map")
           (make-sparse-keymap) 'keymapp
           (format "Auxiliary map for per-buffer user-defined \
keybindings in %s.\n\n%s" state-name doc) t))
    (setq need-local-map
          (vimpulse-define-symbol
           need-local-map
           (concat prefix "need-new-" name-string "-local-map")
           t (lambda (val) (eq val t)) nil t))
    (put need-local-map 'permanent-local t)
    (setq intercept-mode
          (vimpulse-define-symbol
           intercept-mode
           (concat prefixed-name-string "-intercept-minor-mode")
           nil nil
           (format "Mode for binding Viper's vital keys.\n\n%s" doc)))
    (setq intercept-map
          (vimpulse-define-symbol
           intercept-map
           (concat prefixed-name-string "-intercept-map")
           viper-vi-intercept-map 'keymapp
           (format "Keymap for binding Viper's vital keys.\n\n%s" doc)))
    ;; Set up change function
    (if (and change-func (symbolp change-func))
        (setq change change-func)
      (setq change
            (intern (concat prefix "change-state-to-" name-string))))
    (unless (functionp change-func)
      (setq change-func
            `(lambda ()
               ,(format "Change Viper state to %s." state-name)
               (viper-change-state ',state-name))))
    (unless (fboundp change)
      (fset change change-func))
    ;; Remove old index entries
    (dolist (entry (list basic-mode
                         diehard-mode
                         modifier-mode
                         kbd-mode
                         global-user-mode
                         local-user-mode
                         intercept-mode))
      (setq vimpulse-state-maps-alist
            (assq-delete-all entry vimpulse-state-maps-alist)))
    (setq vimpulse-state-modes-alist
          (assq-delete-all state-name vimpulse-state-modes-alist))
    (setq vimpulse-state-vars-alist
          (assq-delete-all state-name vimpulse-state-vars-alist))
    ;; Index keymaps
    (add-to-list 'vimpulse-state-maps-alist
                 (cons basic-mode basic-map))
    (add-to-list 'vimpulse-state-maps-alist
                 (cons diehard-mode diehard-map))
    (add-to-list 'vimpulse-state-maps-alist
                 (cons modifier-mode
                       `(if (keymapp
                             (cdr (assoc major-mode
                                         ,modifier-alist)))
                            (cdr (assoc major-mode
                                        ,modifier-alist)))))
    (add-to-list 'vimpulse-state-maps-alist
                 (cons kbd-mode kbd-map))
    (add-to-list 'vimpulse-state-maps-alist
                 (cons global-user-mode global-user-map))
    (add-to-list 'vimpulse-state-maps-alist
                 (cons local-user-mode local-user-map))
    (add-to-list 'vimpulse-state-maps-alist
                 (cons intercept-mode intercept-map))
    ;; Index minor mode toggling.
    ;; First, sort lists from symbols in :enable.
    (unless (listp enable)
      (setq enable (list enable)))
    (dolist (entry enable)
      (let ((mode entry) (val t))
        (when (listp entry)
          (setq mode (car entry)
                val (cadr entry)))
        (when (and mode (symbolp mode))
          (add-to-list 'enable-modes-alist (cons mode val) t))))
    ;; Then add the state's own modes to the front
    ;; if they're not already there
    (dolist (mode (list (cons basic-mode t)
                        (cons diehard-mode
                              '(not (or viper-want-emacs-keys-in-vi
                                        (viper-is-in-minibuffer))))
                        (cons modifier-mode t)
                        (cons kbd-mode '(not (viper-is-in-minibuffer)))
                        (cons global-user-mode t)
                        (cons local-user-mode t)
                        (cons intercept-mode t)))
      (unless (assq (car mode) enable-modes-alist)
        (add-to-list 'enable-modes-alist mode)))
    ;; Add the result to `vimpulse-state-modes-alist'
    ;; and update any state references therein
    (add-to-list 'vimpulse-state-modes-alist
                 (cons state-name enable-modes-alist) t)
    (vimpulse-refresh-state-modes-alist)
    (viper-normalize-minor-mode-map-alist)
    ;; Index state variables
    (setq vars-alist
          (list (cons 'id id)
                (cons 'hook hook)
                (cons 'change-func change-func)
                (cons 'basic-mode basic-mode)
                (cons 'basic-map basic-map)
                (cons 'diehard-mode diehard-mode)
                (cons 'diehard-map diehard-map)
                (cons 'modifier-mode modifier-mode)
                (cons 'modifier-alist modifier-alist)
                (cons 'kbd-mode kbd-mode)
                (cons 'kbd-map kbd-map)
                (cons 'global-user-mode global-user-mode)
                (cons 'global-user-map global-user-map)
                (cons 'local-user-mode local-user-mode)
                (cons 'local-user-map local-user-map)
                (cons 'need-local-map need-local-map)
                (cons 'intercept-mode intercept-mode)
                (cons 'intercept-map intercept-map)))
    (add-to-list 'vimpulse-state-vars-alist
                 (cons state-name vars-alist) t)
    ;; Make toggle-advice (this is the macro expansion)
    (setq advice (or advice 'after))
    `(defadvice viper-change-state (,advice ,state-name activate)
       ,(format "Toggle %s." state-name)
       ,@body
       (when (eq ',state-name new-state)
         (run-hooks ',hook)))))

(when (fboundp 'font-lock-add-keywords)
  (font-lock-add-keywords
   'emacs-lisp-mode
   '(("(\\(vimpulse-define-state\\)\\>[ \f\t\n\r\v]*\\(\\sw+\\)?"
      (1 font-lock-keyword-face)
      (2 font-lock-function-name-face nil t)))))

;; These are for making `vimpulse-define-state' more forgiving
(defun vimpulse-unquote (exp)
  "Return EXP unquoted."
  (if (and (listp exp)
           (eq 'quote (car exp)))
      (eval exp)
    exp))

(defun vimpulse-define-symbol
  (sym-or-val varname varval &optional val-p doc local)
  "Accept a symbol or a value and define a variable for it.
If SYM-OR-VAL is a symbol, set that symbol's value to VARVAL.
If SYM-OR-VAL is a value, set VARNAME's value to SYM-OR-VAL.
VAL-P checks whether SYM-OR-VAL's value is \"valid\", in which
case it is kept; otherwise we default to VARVAL. DOC is the
docstring for the defined variable. If LOCAL is non-nil,
create a buffer-local variable. Returns the result."
  (cond
   ((and sym-or-val (symbolp sym-or-val)) ; nil is a symbol
    (setq varname sym-or-val))
   ((or (not val-p) (funcall val-p sym-or-val))
    (setq varval sym-or-val)))
  (when (stringp varname)
    (setq varname (intern varname)))
  (unless (and (boundp varname) val-p
               (funcall val-p (eval varname)))
    (eval `(defvar ,varname (quote ,varval) ,doc))
    (set varname varval)
    (when local
      (make-variable-buffer-local varname)))
  varname)

(defun vimpulse-refresh-state-modes-alist (&optional state &rest states)
  "Expand state references in `vimpulse-state-modes-alist'."
  (cond
   (state
    (let* ((state-entry (assq state vimpulse-state-modes-alist))
           (state-list (cdr state-entry))
           mode toggle)
      (setq state-entry nil)
      (dolist (modes (reverse state-list) state-entry)
        (setq mode (car modes))
        (setq toggle (cdr modes))
        (if (and (assq mode vimpulse-state-modes-alist)
                 (not (eq mode state))
                 (not (memq mode states)))
            (setq modes (vimpulse-refresh-state-modes-alist
                         mode (append (list state) states)))
          (setq modes (list modes)))
        (dolist (entry (reverse modes) state-entry)
          (setq state-entry (assq-delete-all (car entry) state-entry))
          (if toggle
              (add-to-list 'state-entry entry)
            (add-to-list 'state-entry (cons (car entry) nil)))))))
   (t
    (dolist (state-entry vimpulse-state-modes-alist)
      (setq state (car state-entry))
      (setq state-entry
            (vimpulse-refresh-state-modes-alist state))
      (setq vimpulse-state-modes-alist
            (assq-delete-all state vimpulse-state-modes-alist))
      (add-to-list 'vimpulse-state-modes-alist
                   (cons state state-entry) t)))))

;;; Viper bugs (should be forwarded to Kifer)

;; `viper-deflocalvar's definition lacks a `declare' statement,
;; so Emacs tends to mess up the indentation. Luckily, the
;; relevant symbol properties can be set up with `put'.
;; TODO: E-mail Michael Kifer about updating the definition
(put 'viper-deflocalvar 'lisp-indent-function 'defun)
(put 'viper-loop 'lisp-indent-function 'defun)
(put 'viper-deflocalvar 'function-documentation
     "Define VAR as a buffer-local variable.
DEFAULT-VALUE is the default value and DOCUMENTATION is the
docstring. The variable becomes buffer-local whenever set.")

(when (fboundp 'font-lock-add-keywords)
  (font-lock-add-keywords
   'emacs-lisp-mode
   '(("(\\(viper-deflocalvar\\)\\>[ \f\t\n\r\v]*\\(\\sw+\\)?"
      (1 font-lock-keyword-face)
      (2 font-lock-variable-name-face nil t))
     ("(\\(viper-loop\\)\\>" 1 font-lock-keyword-face))))

;; e/E bug: on a single-letter word, ce may change two words
(defun vimpulse-end-of-word-kernel ()
  (when (viper-looking-at-separator)
    (viper-skip-all-separators-forward))
  (cond
   ((viper-looking-at-alpha)
    (viper-skip-alpha-forward "_"))
   ((not (viper-looking-at-alphasep))
    (viper-skip-nonalphasep-forward))))

(defun vimpulse-end-of-word (arg &optional careful)
  "Move point to end of current word."
  (interactive "P")
  (viper-leave-region-active)
  (let ((val (viper-p-val arg))
        (com (viper-getcom arg)))
    (cond
     (com
      (viper-move-marker-locally 'viper-com-point (point))
      (when (and (not (viper-looking-at-alpha))
                 (not (viper-looking-at-alphasep)))
        (setq val (1+ val))))
     ((viper-end-of-word-p)
      (setq val (1+ val))))
    (viper-loop val (viper-end-of-word-kernel))
    (if com
        (viper-execute-com 'viper-end-of-word val com)
      (viper-backward-char-carefully))))

(defun vimpulse-end-of-Word (arg)
  "Forward to end of word delimited by white character."
  (interactive "P")
  (viper-leave-region-active)
  (let ((val (viper-p-val arg))
        (com (viper-getcom arg)))
    (cond
     (com
      (viper-move-marker-locally 'viper-com-point (point))
      (when (and (not (viper-looking-at-alpha))
                 (not (viper-looking-at-alphasep)))
        (setq val (1+ val))))
     ((viper-end-of-word-p)
      (setq val (1+ val))))
    (viper-loop val
      (viper-end-of-word-kernel)
      (viper-skip-nonseparators 'forward))
    (if com
        (viper-execute-com 'viper-end-of-word val com)
      (viper-backward-char-carefully))))

(fset 'viper-end-of-word-kernel 'vimpulse-end-of-word-kernel)
(fset 'viper-end-of-word 'vimpulse-end-of-word)
(fset 'viper-end-of-Word 'vimpulse-end-of-Word)

(provide 'vimpulse-viper-function-redefinitions)

