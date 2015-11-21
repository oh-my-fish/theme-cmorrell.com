function __cmorrell_show_vcs_status -d "Displays VCS status"
  if [ (count $argv) = 2 ]
    set -l dirty $argv[1]
    set -l branch $argv[2]

    if [ $dirty != 0 ]
      set_color -b normal
      set_color red
      echo "$dirty changed file"
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
  if [ -d ".git" ]
    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
      set -l dirty (command git status -s --ignore-submodules=dirty | wc -l | sed -e 's/^ *//' -e 's/ *$//' 2> /dev/null)
      set -l ref (command git symbolic-ref --short HEAD 2> /dev/null ; or command git rev-parse --short HEAD 2> /dev/null)

      echo $dirty
      echo $ref
     end
  end
end

function __cmorrell_get_hg_status -d "Gets the current hg status"
  if [ -d ".hg" ]
    if command hg id > /dev/null 2>&1
      set -l dirty (command hg status | wc -l)
      set -l branch (command hg branch)

      echo $dirty
      echo $branch
    end
  end
end

function fish_right_prompt -d "Prints right prompt"
  __cmorrell_show_vcs_status (__cmorrell_get_git_status)
  __cmorrell_show_vcs_status (__cmorrell_get_hg_status)
end
