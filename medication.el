;;; medication.el --- Medication logging for Emacs -*- lexical-binding: t; -*-
;; Copyright (C) 2020-2022 Carwin Young

;; Author: Carwin R. Young <emacs@carw.in>
;; Keywords: org medication
;; Package-Requires: ((org "9.5.3"))
;; This file is not part of GNU Emacs.
;; This file is free software…

;;; Commentary:
;; If you want to quickly log the medications you ingest, and you want
;; to do it with Emacs and Org Mode, this is the package for you.
(require 'org)

(defgroup medication nil
  "medication.el related")

;; When capturing a medication, users will be presented first with a
;; list of drugs, then an amount (in mg). These options are managed by
;; the customizable lists `medication-drug-log-drugs' and
;; `medication-drug-log-amounts-mg'.

;; This package defines some common over-the-counter drugs as default
;; options, but users are expected to customize these variables.
(defcustom medication-drug-log-drugs '("acetaminophen" "ibuprofin" "melatonin")
  "A list of medications to provide as choices when logging drug usage.

Users are expected to override this list with their own list of common
medication amounts."
  :tag "Medication List"
  :group 'medication)

(defcustom medication-drug-log-amounts-mg '("100mg" "200mg" "500mg")
  "A list of common amounts to use for drug logging

Users are expected to override this list with their own list of common
medication amounts."
  :tag "Medication Amounts in Milligrams"
  :group 'medication)

;; These variables pertain to the capture template and the actual log file.
(defcustom medication-capture-key "m"
  "The key to be used for calling the medication drug log capture template."
  :tag "Medication capture key"
  :group 'medication)

(defcustom medication-log-file nil
  "The file to use for logging medication usage."
  :tag "Medication Log File Path"
  :group 'medication)

;; This processes `medication-drug-log-drugs' and presents the list to
;; the user during capture.
(defun medication-select-drug (&optional return-value)
  "Start capturing drug ingestion."
  (let ((medlist medication-drug-log-drugs))
    (setq choice (completing-read "choose: " medication-drug-log-drugs nil nil nil))
    (or (capitalize choice)
        return-value
        (concat "%U - " (capitalize choice)))))

;; This processes `medication-drug-log-amounts-mg' and presents the
;; list to the user for selection.
(defun medication-select-drug-amount-mg ()
  "Present the options to the user and output the value."
  (let ((mglist medication-drug-log-amounts-mg))
    (setq choice (completing-read "amount: " mglist nil nil nil))
    (or choice
        return-value
        choice)))


;; The capture template for drugs is defined using defcustom in case
;; users decide they want to override it with something different.
(defcustom medication-capture-template-drug-log
  `(,medication-capture-key "Drug" entry (file medication-log-file)
                            ,(concat "* %U - %(org-set-property \"what\" (medication-select-drug)) %(org-entry-get (point) \"what\") \n"
                                     ":PROPERTIES:\n"
                                     ":what: \n"
                                     ":when: %U\n"
                                     ":amount: %(medication-select-drug-amount-mg)\n"
                                     ":END:")
                            :empty-lines 1
                            :lines-before 0
                            :lines-after 0
                            :unnarrowed t
                            :prepend t)
  "Customizable capture template for a drug/medication log entry"
  :tag "Drug Log Entry Template"
  :group 'medication)

;; Now the new capture template option gets added to the list of
;; available capture templates.
(add-to-list 'org-capture-templates `(,medication-capture-template-drug-log))

;; Now the package provides itself as a symbol for other files to use.
(provide 'medication)

;; medication.el ends here.
