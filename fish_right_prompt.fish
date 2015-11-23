function __cmrrell_has_in_parent_dirs -d "True if dir exists in parent dirs"
  if [ (count $argv) != 1 ]
    return
  end

  set -l d $argv[1]
  set -l p (pwd)

  while true
    if [ -d "$p/$d" ]
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
  if set -q theme_display_git; and [ $theme_display_git = "no" ]
    return
  end
  if [ ! (__cmrrell_has_in_parent_dirs ".git") ]
    return
  end

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set -l dirty (git status -s --ignore-submodules=dirty | wc -l | sed -e 's/^ *//' -e 's/ *$//' 2> /dev/null)
    set -l ref (git symbolic-ref --short HEAD 2> /dev/null ; or git rev-parse --short HEAD 2> /dev/null)

    echo $dirty
    echo $ref
   end
end

function __cmorrell_get_hg_status -d "Gets the current hg status"
  if set -q theme_display_hg; and [ $theme_display_hg = "no" ]
    return
  end
  if [ ! (__cmrrell_has_in_parent_dirs ".hg") ]
    return
  end

  if hg id > /dev/null 2>&1
    set -l dirty (hg status | wc -l)
    set -l branch (hg branch)

    echo $dirty
    echo $branch
  end
end


function fish_right_prompt -d "Prints right prompt"
  __cmorrell_show_vcs_status (__cmorrell_get_git_status)
  __cmorrell_show_vcs_status (__cmorrell_get_hg_status)
end
