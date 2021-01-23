FROM ubuntu:latest

#ENV TERM screen-256color
ENV DEBIAN_FRONTEND noninteractive
ENV Lang en_us.utf-8


RUN apt-get upgrade && apt-get update && apt-get install -y \
      apt-utils\
      htop \
      bash \
      curl \
      wget \
      git \
      software-properties-common \ 
      sudo \
      zsh

#This is its own thing cause you need software-properties-common to isntall some of this
#So I split it there and then needed other stuff
RUN sudo add-apt-repository universe && apt-get upgrade -y && apt-get update -y && apt-get install -y \
      python-dev \
      #python-pip \
      python3-dev \
      python3-pip \
      ctags \
      shellcheck \
      netcat \
      ack-grep \
      sqlite3 \
      unzip \
      # For python crypto libraries
      libssl-dev \
      libffi-dev \
      locales \
      # For Youcompleteme
      cmake \
      ninja-build \
      gettext \
      libtool \
      libtool-bin \
      autoconf \
      automake \
      g++ \
      pkg-config \
      unzip \
      nodejs \
      npm \
      python3-venv \
      silversearcher-ag \
      tmux 

RUN curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

RUN useradd -ms /bin/bash cburn
USER cburn
RUN curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | zsh || true

USER cburn
RUN mkdir /home/cburn/repos
WORKDIR /home/cburn/repos
#git and make neovim this gets us to 0.4.4
RUN git clone https://github.com/neovim/neovim.git
WORKDIR /home/cburn/repos/neovim
RUN git checkout stable
RUN make
RUN make CMAKE_INSTALL_PREFIX=$HOME/local/nvim install
ENV PATH="/home/cburn/local/nvim/bin:${PATH}"

#COPY ~tmux.conf .tmux.conf

# Install Vim Plug for plugin management
WORKDIR /home/cburn/repos
RUN curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

WORKDIR /home/cburn
COPY nvim .config/nvim/


ENV PATH="/home/cburn/.local/bin:${PATH}"
RUN pip3 install neovim-remote black isort flake8 jedi rope
# Install plugins
RUN nvim +PlugInstall +qall 
# This installs black but then needs an ENTER which we cant do so
RUN timeout 10s nvim --headless +CocInstall; exit 0 
# we run it again and then we dont have coc install its stuff when we run it
RUN timeout 2m nvim --headless +CocInstall; exit 0
# This was something i was exploring but I don't like
# Install Tmux Plugin Manager
#RUN git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm
## Install plugins
#RUN .tmux/plugins/tpm/bin/install_plugins
USER cburn
WORKDIR /workspace
CMD ["nvim"]
