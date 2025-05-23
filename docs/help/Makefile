##
# Copyright © 2023-2025 Charles Choi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

EMACS_ELPA_DIR=$(HOME)/.config/emacs/elpa
EMACS=$(EMACS_APP_EXEC)
PACKAGE_PATHS=-L $(EMACS_ELPA_DIR)/htmlize-current

TARGET_DIR=../../Captee.help/Contents/Resources/en.lproj

.PHONY: create-helpbook
create-helpbook: clean-helpbook build-helpbook indexes

.PHONY: indexes
indexes:
	cd $(TARGET_DIR);hiutil -I lsm -Caf Captee.helpindex -vv .
	cd $(TARGET_DIR);hiutil -I corespotlight -Caf Captee.cshelpindex -vv .

.PHONY: build-helpbook
build-helpbook:
	$(EMACS) -batch $(PACKAGE_PATHS) -l publish-doc.el --eval '(org-publish "captee-help-book" t)'

.PHONY: open-helpbook
open-helpbook:
	open $(TARGET_DIR)/CapteeUserGuide.html

.PHONY: clean-helpbook
clean-helpbook:
	/bin/rm -rf $(TARGET_DIR)/*

.PHONY: entr
entr:
	find . -name '*.org' | entr $(MAKE) create-helpbook

.PHONY: devserver
devserver:
	cd $(TARGET_DIR); python -m http.server

.PHONY: user-guide
dev-user-guide:
	open "http://localhost:8000/CapteeUserGuide.html"
