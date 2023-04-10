##
# Copyright © 2023 Charles Choi
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

MARKETING_VERSION=$(shell grep MARKETING_VERSION config/base.xcconfig | cut -d= -f 2 | xargs)
CURRENT_PROJECT_VERSION=$(shell grep CURRENT_PROJECT_VERSION config/base.xcconfig | cut -d= -f 2 | xargs)

CAPTEE_VERSION = $(MARKETING_VERSION) ($(CURRENT_PROJECT_VERSION))

CAPTEE_VERSION_SNAKE_CASE=$(subst .,_,$(MARKETING_VERSION))

CAPTEE_TAG = captee_$(MARKETING_VERSION).$(CURRENT_PROJECT_VERSION)

MARKETING_VERSION_PATCH_BUMP = $(shell python -c "import semver; print(semver.VersionInfo.parse(\"$(MARKETING_VERSION)\").bump_patch())" | xargs)
MARKETING_VERSION_MINOR_BUMP = $(shell python -c "import semver; print(semver.VersionInfo.parse(\"$(MARKETING_VERSION)\").bump_minor())" | xargs)
MARKETING_VERSION_MAJOR_BUMP = $(shell python -c "import semver; print(semver.VersionInfo.parse(\"$(MARKETING_VERSION)\").bump_major())" | xargs)
CURRENT_PROJECT_VERSION_BUMP = $(shell python -c 'print(int("$(CURRENT_PROJECT_VERSION)") + 1)' | xargs)

.PHONY: version last-log mvers vers bump-patch bump-minor bump-major bump sync-main

version:
	echo "$(CAPTEE_VERSION)"

last-log:
	git --no-pager log --pretty="%T" -1

mvers:
	echo $(MARKETING_VERSION)

vers:
	echo $(CURRENT_PROJECT_VERSION)

# Bump semantic patch field
bump-patch:
	echo $(MARKETING_VERSION_PATCH_BUMP)
	sed -i '' 's/$(MARKETING_VERSION)/$(MARKETING_VERSION_PATCH_BUMP)/' config/base.xcconfig

# Bump semantic minor field
bump-minor:
	echo $(MARKETING_VERSION_MINOR_BUMP)
	sed -i '' 's/$(MARKETING_VERSION)/$(MARKETING_VERSION_MINOR_BUMP)/' config/base.xcconfig

# Bump semantic major field; this will reset minor and patch
bump-major: 
	echo $(MARKETING_VERSION_MAJOR_BUMP)
	sed -i '' 's/$(MARKETING_VERSION)/$(MARKETING_VERSION_MAJOR_BUMP)/' config/base.xcconfig

# Bump build version
bump:
	echo $(CURRENT_PROJECT_VERSION_BUMP)
	sed -i '' 's/CURRENT_PROJECT_VERSION = $(CURRENT_PROJECT_VERSION)/CURRENT_PROJECT_VERSION = $(CURRENT_PROJECT_VERSION_BUMP)/' config/base.xcconfig


sync-main:
	git checkout -b merge-development-to-main development
	git merge main development
	$(MAKE) bump
	git commit -m 'Bumped build.' config/base.xcconfig
	git push origin merge-development-to-main
	gh pr create -t 'Merge development to main' -b 'Merge development to main' -B main

tag:
	git tag $(CAPTEE_TAG)

