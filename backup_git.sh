#!/bin/bash

git=$(which git)
log=".bash-scripts/logs/lrc-logs.txt"
merge_branch="hotfix/temp"
main_branch="backup-test"
current_date="$(date +%F@%H:%M)"
project_path="/lrc/woocommerce-site"
dumper_path=".db-tools/bin/dumper --no-gtid --output-folder database etc/lrc-vars.ini"

cd ${project_path}
mkdir -p .bash-scripts/logs
touch ${log}
echo "logs from ${current_date}" >> ${log}

${git} fetch
status=$(${git} status -s 2>&1)
if ["${status}" == ""]; then
  echo "All well done" >> ${log}
  echo "${status}" >> ${log}
  ${git} pull origin ${main_branch} >> ${log}
  # execute dumper
  ${dumper_path}
  ${git} add .
  ${git} commit -m "autosave ${current_date}"
  ${git} push origin ${main_branch}
  echo "All well done on the push on IF ${current_date}" >> ${log}
else
  echo "There are uncommited changes" >> ${log}
  echo "${status}" >> ${log}
  ${git} switch -c ${merge_branch}
  ${git} add .
  ${git} commit -m "autosave ${current_date}"
  ${git} branch -D ${main_branch}
  ${git} switch -c ${main_branch} origin/${main_branch}
  ${git} pull origin ${main_branch}
  ${git} switch ${merge_branch}
  ${git} rebase ${main_branch}
  ${git} switch ${main_branch}
  ${git} merge --no-edit ${merge_branch}
  # execute dumper
  ${dumper_path}
  ${git} add .
  ${git} commit --amend --no-edit
  ${git} push origin ${main_branch}
  ${git} branch -D ${merge_branch}
  echo "All well done on the push on ELSE ${current_date}" >> ${log}
fi