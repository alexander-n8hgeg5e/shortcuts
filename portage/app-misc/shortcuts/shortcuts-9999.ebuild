# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_6 )
inherit git-r3 eutils scons-utils
DESCRIPTION="shortcuts"
HOMEPAGE=""
EGIT_REPO_URI="${CODEDIR}""/shortcuts https://github.com/alexander-n8hgeg5e/shortcuts.git"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="rind neovim github pyopen X"

DEPEND=""
RDEPEND="${DEPEND} dev-python/pexpect
                   >=dev-python/columnize-0.3.9
				   x11-misc/wmctrl
                   rind? ( app-misc/rind )
                   neovim? ( app-editors/neovim
				             app-misc/tmux
						   )
                   github? ( dev-python/github3 )
                   pyopen? ( app-misc/pyopen )
				   X? ( x11-apps/xset dev-python/psutil dev-util/scons )
				   "
src_configure(){
	true;
}
src_compile(){
	if use X;then
    	escons
	fi
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
dobin setup_x
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
dosym rgc /usr/bin/rgic    # alias
dosym sgc /usr/bin/sgic    # alias
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
dobin dg
dobin haw
dobin preloadwins
dobin i
dobin compile_in_kernel_loaded_modules
dobin realtime
dobin nvim_open_browsertab
dobin synergy_tmrl_esadc_client
dobin synergy_tmrl_esadc_server
dobin tmux_nvim_update_nvim_listen_addr
dobin tmrl_blo
dobin rh
dobin rl
dobin xc
dobin tmrlfs
dobin sed_inplace_insert_between_lines
dobin sed_inplace_insert_dobin_into_ebuild
dobin rallnodes
dobin check_synergy_ssh_connection
dobin _check_synergy_ssh_connection
if use X ; then
	dobin menu/r_menuwin
	dobin menu/l_menuwin
	dobin menu/menuwin
	dobin menu/menu_run
	dobin menu/menu_search
fi
dobin qb
dobin ginf
dobin pcfs
dobin gip
dobin gb
dobin set_portage_access_to_code
dobin unabsorb_git_dirs
dobin random_seq
dobin get_free_nodes
dobin check_node
dobin check_nodes
dobin get_nodes_load
dobin get_node_load
dobin list_my_procs_on_nodes
dobin list_proc_on_node_by_pid
dobin list_my_procs_on_node
dobin list_my_procs_on_nodes_sorted
dobin get_submodule_path_list
dobin wget_em
dobin snap
dobin gbrd
dobin gbr
dobin gprh
dobin gcb
dobin get_dotf_gitdirs
dobin get_root_gitdirs
dobin get_home_gitdirs
dobin pp
dobin gh
dobin ds
dobin gsu
dobin gsd
dobin guno
dobin kernel_update
dobin github
dobin gsbrd
dobin gisfor
dobin gcb
dobin gbs
dobin gsuf
dobin "gsu!"
dobin gscb
dobin checkout_failed
dobin conky_all
dobin parse_xrandr_conf
dobin setup_xrandr
dobin set_max_cpu_f
dobin maups
dobin gsb
dobin gsc
dobin git_change_commit_date
dobin datef
dobin git_del_all_worktree_conf
dobin ghb
dobin elpauc!
dobin elpauc
dobin elpauc!!
dobin gcmb
dobin gbrod
dobin gbro
dobin git_update_process
dobin get_latest_portage_build_logs
dobin write_latest_portage_build_logs_to_shm
dobin klima_off
dobin klima_on
dobin sc
dobin xauth_push
dobin ovpn
dobin invert_and_darken_screen
dobin darken_screen
dobin blink
dobin dedupe
dobin dotf_gsu
dobin .g
dobin .g.
dobin .g.c
dobin .ga
dobin .gb
dobin .gbr
dobin .gbrd
dobin .gbro
dobin .gbrod
dobin .gbs
dobin .gcb
dobin .gcmb
dobin .gh
dobin .ghb
dobin .gi
dobin .gic
dobin .gl
dobin .gpc
dobin .gprh
dobin .grt
dobin .gsb
dobin .gsbrd
dobin .gsc
dobin .gscb
dobin .gsd
dobin .gsu
dobin .gsuf
dobin .gu
dobin .guc
dobin .guno
dobin .gd
dobin .gdc
dobin grt
dobin gd
dobin gdc
dobin erc
dobin uerc
dobin uerc!
dobin uerc!!
dobin xauth_pull
dobin xis
dobin tmrlso
dobin youtube
dobin xi
dobin gg
dobin sed_comment_exclude_git
dobin prepare_nvim_git_history
dobin n
dobin screen_on_control_1
dobin screen_on_control
dobin colorfade
dobin mm
dobin .gdcs
dobin .gds
dobin gds
dobin gdcs
dobin gidb
dobin mirrorlink
dobin homelink
dobin run_env_eprefix_shebang
dobin timewatch
dobin old
dobin feedkeys_screen
dobin wm_conf_adj
dobin add_modelines
dobin pav
dobin k
dobin pyprep
dobin webserv
dobin tt
dobin I
dosym gur /usr/bin/git-unpack-refs    # alias
dobin git-unpack-refs
dobin gco
dobin synergy_skyscraper
dobin pw
dobin lf
dobin pf
dobin iit
dobin iit2
dobin iit3
dobin iit4
dobin it
dobin it1
dobin it2
dobin it3
dobin it4
dobin py
dobin cl
dobin p2c
dobin pw2handy
dobin G
dobin group_access
dobin check_git
dobin pip3_source_download
dobin wl
dobin dms
dobin stripcolors
dobin gl1
dobin cmdowner
dobin iptables_log_rejected
dobin w3mimgdisplay
dobin ssnd
dobin stnd
dobin srnd
dobin bn
dobin msky
dobin skyscraper_activate_monitor_onoff_button
dobin monitor_samsung_control
dobin mec
dobin git_reverse_graph_color
dobin fgd
dobin ff
dobin datesort
dobin snap2
dobin check_userids_groupids
dobin eixv
}
