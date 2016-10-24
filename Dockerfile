FROM ubuntu:trusty

RUN locale-gen en_US en_US.UTF-8 \
  && dpkg-reconfigure locales

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install general dependencies
RUN apt-get update && apt-get install -y build-essential git curl libssl-dev libreadline-dev zlib1g-dev

# get the latest version of node
# https://nodejs.org/en/download/package-manager/
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - \
	&& apt-get install -y nodejs

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
