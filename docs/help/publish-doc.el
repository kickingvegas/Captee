;; Copyright © 2023 Charles Choi
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

;; This is specific to cchoi personal configuration
(add-to-list 'load-path "~/.config/emacs/elpa/org-9.6.5/")
(add-to-list 'load-path "~/.config/emacs/elpa/htmlize-20210825.2150")

(require 'org)
(require 'htmlize)
(require 'ox-html)
(require 'ox-publish)

(setq org-publish-project-alist
      `(("pages"
         :base-directory "."
         :base-extension "org"
         :recursive t
         :publishing-directory "../../Captee.help/Contents/Resources/en.lproj"
         :publishing-function org-html-publish-to-html)

        ("static"
         :base-directory "."
         :base-extension "css\\|txt\\|jpg\\|gif\\|png\\|svg\\|helpindex\\|cshelpindex"
         :recursive t
         :publishing-directory "../../Captee.help/Contents/Resources/en.lproj"
         :publishing-function org-publish-attachment)
        
        ("captee-help-book"
         :components ("pages" "static"))))
