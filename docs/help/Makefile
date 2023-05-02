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

TARGET_DIR=../../Captee.help/Contents/Resources/en.lproj

.PHONY: indexes

indexes:
	cd $(TARGET_DIR);hiutil -I lsm -Caf Captee.helpindex -vv .
	cd $(TARGET_DIR);hiutil -I corespotlight -Caf Captee.cshelpindex -vv .

hey:
	ls $(TARGET_DIR)
