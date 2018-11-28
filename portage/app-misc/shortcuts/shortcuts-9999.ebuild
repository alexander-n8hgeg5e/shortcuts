# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit git-r3 eutils
DESCRIPTION="shortcuts"
HOMEPAGE=""
EGIT_REPO_URI="${CODEDIR}""/shortcuts https://github.com/alexander-n8hgeg5e/shortcuts.git"

LICENSE=""
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND} dev-python/pexpect"
src_configure(){
	true;
}
src_compile(){
	true;
}


src_install(){
dobin c
dobin convert_all_mp4_2_aac
dobin disk_smart_report
dobin dotf
dobin e
dobin edit_nvim_win_back
dobin edit_nvim_tag_browser
dobin elp
dobin elpau
dobin elpau!
dobin elpau!!
dobin extra_disk_einbinden
dobin g
dobin g.c
dobin ga
dobin gi
dobin git_commit_nvim
dobin github_create_repo
dobin gl
dobin goo
dobin gpc
dobin guc
dobin img_comp_all_here
dobin keyblayout_set
dobin l
dobin m
dobin mail_attach_mutt_nvim
dobin mailstart
dobin manif
dobin maup
dobin mount-notmuchfs
dobin mutt-notmuch
dobin np
dobin nvim_commit_git_history
dobin nvim_git_history
dobin obexit
dobin p1
dobin pc
dobin pwfind
dobin rg
dobin rg
dobin rg.c
dobin rga
dobin rga
dobin rgi
dobin rgl
dobin rgpc
dobin rguc
#dobin rsync_handy2_dcimdir_fast
#dobin rsync_handy_dcimdir_fast
dobin sd
dobin speech-wrapper
dobin gi
dobin github_create_repo
dobin nvim_commit_git_history
dobin nvim_git_history
dobin c
dobin gl
dobin print_foldable
dobin sus
dobin u
dobin umount-notmuchfs
dobin de_st_nvim
dobin st_nvim
dobin t
doman mutt-notmuch.1
dobin list_firewall
dobin setXkeyboardstuff
dobin gu
dobin g.
dobin ga
dobin ga
dobin g.
dobin gu
dobin rga
dobin rg.
dobin rgu
dobin rgit
dobin rg
dobin rg.
dobin rg.c
dobin rga
dobin rgi
dobin rgit
dobin rgl
dobin rgpc
dobin rgu
dobin rguc
dobin rgc
dobin gic      # file collison , should be gc
dosym ${EPREFIX}/usr/bin/rgc ${EPREFIX}/usr/bin/rgic    # alias
dosym ${EPREFIX}/usr/bin/sgc ${EPREFIX}/usr/bin/sgic    # alias
dobin sgc
dobin sg.
dobin sg.c
dobin sga
dobin sgc
dobin sgit
dobin sgits # sg collision
dobin sgl
dobin sgpc
dobin sgu
dobin sguc
dobin sgi
dobin cg
dobin cg.
dobin cg.c
dobin cga
dobin cgc
dobin cgi
dobin cgit
dobin cgl
dobin cgpc
dobin cgu
dobin cguc
dobin r
dobin set_nvim_var
dobin rub
dobin nvim_call
dobin nvim_command
insinto /usr/share/applications
doins w3m.desktop
dobin br
dobin bh
dobin l0
dobin l1
dobin ic
dobin st_de_nvim
dobin tv
dobin tmux_nvim_session
dobin tmux_nvim_new_session
dobin mknewappuser
dobin saau
dobin ba
dobin ne
}
