export LC_COLLATE=C
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export TERM=xterm-color

[[ -d "/usr/local/apache2/bin" ]] && export PATH=$PATH:/usr/local/apache2/bin

if [ -f /usr/bin/vim ]; then
        if [ -f /etc/defaults.vim ]; then
                export VIMINIT='source /etc/defaults.vim'
        fi
        export EDITOR='/usr/bin/vim'
        alias vi='vim -u ${HOME}/.vim/vimrc'
fi

if [ -f /usr/bin/bc ]; then
	unalias bc
	alias calc='bc'
fi
