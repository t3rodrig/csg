#! /bin/bash
#
# Copyright 2009 The VOTCA Development Team (http://www.votca.org)
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

if [ "$1" = "--help" ]; then
cat <<EOF
${0##*/}, version %version%
This script implemtents the function update
for the Inverse Boltzmann Method for a single pair

Usage: ${0##*/} step_nr

USES:  die do_external die csg_get_interaction_property check_deps get_current_step_nr


EOF
   exit 0
fi

check_deps "$0"

step_nr=$(get_current_step_nr)
scheme=( $(csg_get_interaction_property inverse.do_potential 1) )
scheme_nr=$(( ($step_nr - 1 ) % ${#scheme[@]} ))
name=$(csg_get_interaction_property name)

if [ "${scheme[$scheme_nr]}" = 1 ]; then
   echo "Update potential ${name} : yes"
   #update ibi
   do_external resample target
   do_external update ibi_pot ${name}.dist.tgt ${name}.dist.new ${name}.pot.cur ${name}.dpot.tmp
   do_external dpot shift_nb ${name}.dpot.tmp ${name}.dpot.new
else
   echo "Update potential ${name} : no"
   min=$(csg_get_interaction_property min)
   step=$(csg_get_interaction_property step)
   max=$(csg_get_interaction_property max)
   do_external table dummy ${min}:${step}:${max} ${name}.dpot.new
fi