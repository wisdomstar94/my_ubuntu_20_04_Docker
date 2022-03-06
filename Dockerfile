# 우분투 OS로 지정
FROM ubuntu:20.04

# 라벨 지정
LABEL "MAINTAINER"="Shin Jae Hyeon"
LABEL "DESCRIPTION"="Install what you need on ubuntu:20.04"

# apt-get update 진행
RUN apt-get update -y

# apt-get upgrade 진행
RUN apt-get upgrade -y

# 기본적인 패키지 설치 및 환경설정 진행
# echo 6 => ASIA 선택한다는 뜻
# ECHO 69 => Seoul 선택한다는 뜻
# 시간대가 Asia/Seoul 로 설정됨
RUN (echo 6 ; echo 69) | apt-get install net-tools cron systemd curl wget vim cmake gcc g++ -y

# 한글 UTF-8 언어팩 설치 및 적용
# 언어셋이 ko_KR.UTF-8 로 설정됨
RUN apt-get install language-pack-ko -y
RUN locale-gen ko_KR.UTF-8
RUN update-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX
RUN export LANG=ko_KR.UTF-8

# Node.js 16.x 설치
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs

# 필요한 npm 패키지 전역 설치
RUN npm i -g pm2 @angular/core @angular/cli

# git 2.35.1 설치
RUN apt-get install libssl-dev libcurl4-gnutls-dev zlib1g-dev gettext -y
WORKDIR /usr/src
RUN wget https://www.kernel.org/pub/software/scm/git/git-2.35.1.tar.gz
RUN tar -xvzf git-2.35.1.tar.gz
WORKDIR /usr/src/git-2.35.1
RUN ./configure --prefix=/usr/local/git
RUN make && make install

# golang 1.17.8 설치
WORKDIR /usr/src
RUN wget https://golang.org/dl/go1.17.8.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.17.8.linux-amd64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin

# 컨테이너가 LISTEN 할 포트 지정
# EXPOSE 80
# EXPOSE 443

# MariaDB 10.6.5 설치 (mysql_secure_installation 으로 초기 셋팅 필요)
RUN apt-get install software-properties-common -y
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
RUN add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.lstn.net/mariadb/repo/10.6/ubuntu focal main'
RUN apt update -y
RUN apt install mariadb-server -y

# MariaDB 기본 언어셋 UTF-8로 설정
RUN sed -i'' -r -e "/\[mysql\]/a\default-character-set = utf8mb4" /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysql_upgrade\]/a\default-character-set = utf8mb4" /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqladmin\]/a\default-character-set = utf8mb4" /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlbinlog\]/a\default-character-set = utf8mb4" /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlcheck\]/a\default-character-set = utf8mb4" /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqldump\]/a\default-character-set = utf8mb4" /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlimport\]/a\default-character-set = utf8mb4" /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlshow\]/a\default-character-set = utf8mb4" /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf \
&& sed -i'' -r -e "/\[mysqlslap\]/a\default-character-set = utf8mb4" /etc/mysql/mariadb.conf.d/50-mysql-clients.cnf

# MariaDB bind-address 를 0.0.0.0 으로 변경 (호스트OS에서 컨테이너의 MariaDB에 HeidiSQL 같은 툴로 접근하기 위함)
RUN sed -i'' -r -e "s/bind-address/\# bind-address/" /etc/mysql/mariadb.conf.d/50-server.cnf
RUN sed -i'' -r -e "/bind-address            = 127.0.0.1/a\bind-address            = 0.0.0.0" /etc/mysql/mariadb.conf.d/50-server.cnf

# db_init go 파일 빌드
COPY db_init.go /root/db_init.go
WORKDIR /root
RUN /usr/local/go/bin/go build db_init.go

# 컨테이너 실행시 구동할 내용 설정
RUN mkdir /sh
COPY execute_when_starting.sh /sh/execute_when_starting.sh
RUN sed -i'' -r -e "/this file has to be sourced in/asource /sh/execute_when_starting.sh" /etc/bash.bashrc

# 루트 경로로 이동
WORKDIR /

# 컨테이너가 시작될 때마다 실행할 명령어(커맨드) 설정
CMD ["/bin/bash"]
