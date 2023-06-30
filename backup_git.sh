#!/bin/bash

git=`which git`
log="logs/lrc-logs.txt"
merge_branch="hotfix/temp"
main_branch="main"
current_date="$(date +%F@%H:%M)"
dumper_path=".db-tools/bin/dumper --no-gtid --output-folder database etc/lrc-vars.ini"

echo "logs from ${current_date}" > ${log}
mkdir -p logs
touch ${LOG}

${git} fetch
status = "${git} status -s"
if ["$status" == ""]; then
  ${git} pull >> ${log}
  # execute dumper
  ${git} add .
  ${git} commit -m "autosave ${current_date}"
  ${git} push origin ${main_branch}
  echo "All well done on the push ${current_date}" > ${log}
else
  echo "There are uncommited changes" > ${log}
  echo "${status}" > ${log}
  ${git} switch -c ${merge_branch}
  ${git} add .
  ${git} commit -m "uncommited changes"
  ${git} pull origin ${main_branch}
  ${git} add .
  ${git} commit --amend "autosave ${current_date}"
  ${git} switch ${main_branch}
  ${git} merge --no-ff --no-edit ${merge_branch}
  ${git} push origin ${main_branch}
  ${git} branch -D ${merge_branch}
fi


