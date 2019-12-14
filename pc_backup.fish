#!/mnt/home/username/gentoo/bin/fish

set HOME "/mnt/home/username"
set git_dir $HOME"/.backup.git"
set work_tree $HOME

function rename
    for i in (find $HOME -name '.git')
        mv $i $i.temp_off_during_backup
    end
end

function rename_back
    for i in (find $HOME -name '.git.temp_off_during_backup')
        set a (echo $i)
        set b (echo $i |rev|cut -c 24-|rev)
        mv $a $b
    end
end

#rename
#git --git-dir=$git_dir --work-tree=$work_tree add $HOME
rename_back
#git --git-dir=$git_dir --work-tree=$work_tree status
#git --git-dir=$git_dir --work-tree=$work_tree init


    

