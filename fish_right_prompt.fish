function __cmrrell_has_on_parent_dirs -d "True of dir exists in parent dirs"
  if [ (count $argv) != 1 ]
    return
  end

  set -l p (pwd)
  while true
    if [ -d $argv[1] ]
      echo 1
      return
    end
    if [ $p = "/" ]
      return
    end
    set p (readlink -f "$p/..")
  end
end

function __cmorrell_show_vcs_status -d "Displays VCS status"
  if [ (count $argv) = 2 ]
    set -l dirty $argv[1]
    set -l branch $argv[2]

    if [ $dirty != 0 ]
      set_color -b normal
      set_color red
      echo " $dirty changed file"
      if [ $dirty != 1 ]
        echo "s"
      end
      echo " "
      set_color -b red
      set_color white
    else
      set_color -b cyan
      set_color white
    end

    echo " $branch "
    set_color normal
  end
end


function __cmorrell_get_git_status -d "Gets the current git status"
  set -l has (__cmrrell_has_on_parent_dirs ".git")
  if [ $has ]
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
      set -l dirty (git status -s --ignore-submodules=dirty | wc -l | sed -e 's/^ *//' -e 's/ *$//' 2> /dev/null)
      set -l ref (git symbolic-ref --short HEAD 2> /dev/null ; or git rev-parse --short HEAD 2> /dev/null)

      echo $dirty
      echo $ref
     end
  end
end

function __cmorrell_get_hg_status -d "Gets the current hg status"
  set -l has (__cmrrell_has_on_parent_dirs ".hg")
  if [ $has ]
    if hg id > /dev/null 2>&1
      set -l dirty (hg status | wc -l)
      set -l branch (hg branch)

      echo $dirty
      echo $branch
    end
  end
end


function fish_right_prompt -d "Prints right prompt"
  __cmorrell_show_vcs_status (__cmorrell_get_git_status)
  __cmorrell_show_vcs_status (__cmorrell_get_hg_status)
end
