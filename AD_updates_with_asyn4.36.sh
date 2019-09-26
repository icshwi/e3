#!/bin/bash
#
#  Copyright (c) 2019  European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Author  : Jeong Han Lee
# email   : jeonghan.lee@gmail.com
# Date    : Thursday, September 26 10:01:13 CEST 2019
# version : 0.0.1

GIT_URL="https://github.com/icshwi"
GIT_CMD="git clone"

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="${SC_SCRIPT%/*}"


. ${SC_TOP}/.cfgs/.e3_functions.cfg


pushd ${SC_TOP}

rebuild_module "ADSupport" "devel/R1-9"
rebuild_module "ADCore"    "devel/R3-7"

git_clone "e3-ADGenICam" 
git_clone "e3-ADSpinnaker" 

rebuild_module "ADGenICam"
rebuild_module "ADSpinnaker"

popd

