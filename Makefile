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

TIMESTAMP := $(shell /bin/date "+%Y%m%d_%H%M%S")
INSTALL_DIR=$(HOME)/bin
EXEC_NAME=Captee
EXEC_LOWER_NAME=captee

BASE_CONFIG=./config/base.xcconfig

BUILD_NUMBER := $(shell ./scripts/read-current-project-version.sh $(BASE_CONFIG))
SEMVER := $(shell ./scripts/read-marketing-version.sh $(BASE_CONFIG))
# BUMP_LEVEL: major|minor|patch|prerelease|build
BUMP_LEVEL=patch
SEMVER_BUMP := $(shell python -m semver bump $(BUMP_LEVEL) $(SEMVER))
NEXT_BUILD = $(shell echo "$(BUILD_NUMBER) + 1" | bc)
VERSION = "$(SEMVER) ($(BUILD_NUMBER))"
RELEASE_TAG = "$(EXEC_LOWER_NAME)_$(SEMVER).$(BUILD_NUMBER)"

.PHONY: version
version:
	echo $(VERSION)

.PHONY: bump-build
bump-build:
	sed -i 's/CURRENT_PROJECT_VERSION = $(BUILD_NUMBER)/CURRENT_PROJECT_VERSION = $(NEXT_BUILD)/' $(BASE_CONFIG)
	git commit -m 'Bump CURRENT_PROJECT_VERSION to $(NEXT_BUILD)' $(BASE_CONFIG)
	git push

.PHONY: bump-semver
bump-semver:
	sed -i 's/MARKETING_VERSION = $(SEMVER)/MARKETING_VERSION = $(SEMVER_BUMP)/' $(BASE_CONFIG)
	git commit -m 'Bump MARKETING_VERSION to $(SEMVER_BUMP)' $(BASE_CONFIG)
	git push

.PHONY: checkout-development
checkout-development:
	git checkout development
	git branch --set-upstream-to=origin/development development
	git fetch origin --prune
	git pull

.PHONY: checkout-main
checkout-main:
	git checkout main
	git branch --set-upstream-to=origin/main main
	git fetch origin --prune
	git pull

.PHONY: sync-development-with-main
sync-development-with-main: checkout-main checkout-development
	git merge main

.PHONY: new-sprint
new-sprint: SEMVER_BUMP:=$(shell python -m semver nextver $(SEMVER) patch)
new-sprint: sync-development-with-main bump-semver

.PHONY: create-merge-development-branch
create-merge-development-branch: checkout-development
	git checkout -b merge-development-to-main-$(TIMESTAMP)
	git push --set-upstream origin merge-development-to-main-$(TIMESTAMP)

## Create GitHub pull request for development
.PHONY: create-pr
create-pr:
	gh pr create --base development --fill

.PHONY: create-patch-pr
create-patch-pr:
	gh pr create --base main --fill

## Create GitHub pull request for release
.PHONY: create-release-pr
create-release-pr: create-merge-development-branch
	gh pr create --base main \
--title "Merge development to main $(TIMESTAMP)" \
--fill-verbose

.PHONY: create-release-tag
create-release-tag: checkout-main
	git tag $(RELEASE_TAG)
	git push origin $(RELEASE_TAG)

.PHONY: create-gh-release
create-gh-release: create-release-tag
	gh release create --draft --title v$(VERSION) --generate-notes $(RELEASE_TAG)

.PHONY: test
test:
	xcodebuild test -scheme $(EXEC_NAME)

.PHONY: create-helpbook
create-helpbook:
	make -C docs/help $@

.PHONY: clean-helpbook
clean-helpbook:
	make -C docs/help $@

.PHONY: status
status:
	git status
