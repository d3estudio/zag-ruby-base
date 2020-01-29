FROM ubuntu

#ADD file:feb9fd29475961253e3449db036bbf56bf6f4d02f2df1202209e393a9e7e95f5 in /
CMD ["bash"]
RUN apt-get update \
    && apt-get install -y --no-install-recommends 		ca-certificates 		curl 		netbase 		wget 	\
    && rm -rf /var/lib/apt/lists/*
RUN set -ex; 	if ! command -v gpg > /dev/null; then 		apt-get update; 		apt-get install -y --no-install-recommends 			gnupg 			dirmngr 		; 		rm -rf /var/lib/apt/lists/*; 	fi
RUN apt-get update \
    && apt-get install -y --no-install-recommends 		bzr 		git 		mercurial 		openssh-client 		subversion 				procps 	\
    && rm -rf /var/lib/apt/lists/*
RUN set -ex; 	apt-get update; 	apt-get install -y --no-install-recommends 		autoconf 		automake 		bzip2 		dpkg-dev 		file 		g++ 		gcc 	imagemagick 		libbz2-dev 		libc6-dev 		libcurl4-openssl-dev 		libdb-dev 	libevent-dev 		libffi-dev 		libgdbm-dev 		libgeoip-dev 		libglib2.0-dev 		libjpeg-dev 		libkrb5-dev 		liblzma-dev 		libmagickcore-dev 		libmagickwand-dev 		libncurses5-dev 		libncursesw5-dev 		libpng-dev 		libpq-dev 	libreadline-dev 		libsqlite3-dev 		libssl-dev 		libtool 		libwebp-dev 		libxml2-dev 		libxslt-dev 		libyaml-dev 		make 		patch 		unzip 		xz-utils 		zlib1g-dev 				$( 			if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then 				echo 'default-libmysqlclient-dev'; 			else 				echo 'libmysqlclient-dev'; 			fi 		) 	; 	rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/etc 	\
    && { 		echo 'install: --no-document'; 		echo 'update: --no-document'; 	} >> /usr/local/etc/gemrc
ENV RUBY_MAJOR=2.6
ENV RUBY_VERSION=2.6.5
ENV RUBY_DOWNLOAD_SHA256=d5d6da717fd48524596f9b78ac5a2eeb9691753da5c06923a6c31190abe01a62
RUN set -ex 		\
    && buildDeps=' 		bison 		dpkg-dev 		libgdbm-dev 		ruby 	' 	\
    && apt-get update 	\
    && apt-get install -y --no-install-recommends $buildDeps 	\
    && rm -rf /var/lib/apt/lists/* 		\
    && wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz" 	\
    && echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c - 		\
    && mkdir -p /usr/src/ruby 	\
    && tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 	\
    && rm ruby.tar.xz 		\
    && cd /usr/src/ruby 		\
    && { 		echo '#define ENABLE_PATH_CHECK 0'; 		echo; 		cat file.c; 	} > file.c.new 	\
    && mv file.c.new file.c 		\
    && autoconf 	\
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" 	\
    && ./configure 		--build="$gnuArch" 		--disable-install-doc 		--enable-shared 	\
    && make -j "$(nproc)" 	\
    && make install 		\
    && apt-get purge -y --auto-remove $buildDeps 	\
    && cd / 	\
    && rm -r /usr/src/ruby 	\
    && ruby --version \
    && gem --version \
    && bundle --version
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=/usr/local/bundle BUNDLE_SILENCE_ROOT_WARNING=1 BUNDLE_APP_CONFIG=/usr/local/bundle
ENV PATH=/usr/local/bundle/bin:/usr/local/bundle/gems/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN mkdir -p "$GEM_HOME" \
    && chmod 777 "$GEM_HOME"
RUN apt-get update \
    && apt-get install --force-yes -y     build-essential     imagemagick     locales     libpq-dev \
    && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8

ENV NODEJS_VERSION=v10.15.0
ENV NODEJS_DOWNLOAD_URL=https://nodejs.org/dist/v10.15.0/node-v10.15.0-linux-x64.tar.xz
ENV NODEJS_SHASUM=https://nodejs.org/dist/v10.15.0/SHASUMS256.txt.asc

ADD ${NODEJS_DOWNLOAD_URL} tmp/
ADD ${NODEJS_SHASUM} tmp/

RUN cd /tmp && sha256sum -c SHASUMS256.txt.asc 2>&1 | grep OK
RUN mkdir /usr/local/lib/nodejs
RUN cd /tmp \
    && tar -xJf node-$NODEJS_VERSION-linux-x64.tar.xz -C /usr/local/lib/nodejs
RUN mv /usr/local/lib/nodejs/node-$NODEJS_VERSION-linux-x64 /usr/local/lib/nodejs/node-$NODEJS_VERSION
RUN update-alternatives --install /usr/bin/npm      npm /usr/local/lib/nodejs/node-$NODEJS_VERSION/lib/node_modules/npm/bin/npm-cli.js  10
RUN update-alternatives --install /usr/bin/nodejs   nodejs /usr/local/lib/nodejs/node-$NODEJS_VERSION/bin/node                          10
RUN update-alternatives --install /usr/bin/node     node /usr/local/lib/nodejs/node-$NODEJS_VERSION/bin/node                            10
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
RUN rm -rfv node-$NODEJS_VERSION-linux-x64.tar.xz
ENV PATH=/usr/local/bundle/bin:/usr/local/bundle/gems/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.yarn/bin