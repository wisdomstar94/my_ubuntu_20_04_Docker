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
RUN (echo 6 ; echo 69) | apt-get install net-tools cron systemd curl wget vim cmake gcc -y

# 한글 UTF-8 언어팩 설치 및 적용
# 언어셋이 ko_KR.UTF-8 로 설정됨
RUN apt-get install language-pack-ko -y
RUN locale-gen ko_KR.UTF-8
RUN update-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX
RUN export LANG=ko_KR.UTF-8
RUN sed -i'' -r -e "/this file has to be sourced in/a\export LANG=ko_KR.UTF-8" /etc/bash.bashrc

# Node.js 14.x 설치
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# 필요한 npm 패키지 전역 설치
RUN npm i -g pm2 @angular/core @angular/cli

# 컨테이너가 LISTEN 할 포트 지정
EXPOSE 80
EXPOSE 443

# 컨테이너가 시작될 때마다 실행할 명령어(커맨드) 설정
CMD ["/bin/bash"]
