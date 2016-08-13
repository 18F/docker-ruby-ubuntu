FROM ubuntu:trusty

RUN locale-gen en_US en_US.UTF-8 \
  && dpkg-reconfigure locales

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install general dependencies
RUN apt-get update && apt-get install -y build-essential git curl libssl-dev libreadline-dev zlib1g-dev

# install nvm and install versions 4 and 6
ENV NVM_DIR /usr/local/nvm
ENV NODE_DEFAULT_VERSION 4
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.31.3/install.sh | bash \
  && . "$NVM_DIR/nvm.sh" \
  && nvm install $NODE_DEFAULT_VERSION \
  && nvm install 6 \
  && nvm use $NODE_DEFAULT_VERSION
ENV NODE_PATH $NVM_DIR/v$NODE_DEFAULT_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_DEFAULT_VERSION/bin:$PATH

# skip installing gem documentation
RUN echo 'install: --no-document\nupdate: --no-document' >> "$HOME/.gemrc"

# Install ruby via ruby-build
ENV RUBY_VERSION 2.3.1
RUN git clone https://github.com/rbenv/ruby-build.git $HOME/ruby-build \
  && cd $HOME/ruby-build \
  && ./install.sh \
  && ruby-build --verbose $RUBY_VERSION /usr/ \
  && cd / && rm -rf $HOME/ruby-build

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH

ENV BUNDLER_VERSION 1.13.5

RUN gem install bundler --version "$BUNDLER_VERSION" \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin"

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME
