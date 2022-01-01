#
# my_ubuntu_20_04 이미지
1. ko_KR.UTF-8 언어셋으로 설정됨
2. 시간대 Asia/Seoul 으로 설정됨
3. Node.js 16.x 설치됨
4. git 2.34.1 설치됨
5. pm2, @angular/core, @angular/cli 패키지가 전역으로 설치됨
6. MariaDB 10.6.5 설치됨 (mysql_secure_installation 으로 초기 셋팅 필요), mysql 5.7 용 Dockerfile 도 따로 제공
7. go 1.17.5 설치됨

#

# db default 접속 정보
컨테이너 구동시 mariadb 혹은 mysql 이 자동으로 실행되며, 기본 접속 정보는 아래와 같습니다.
(단, 현재로써 mysql 용 컨테이너인 경우에는 컨테이너 실행 후, 컨테이너 안으로 최초 1번 접속해야 호스트 os에서 db 접속 툴로 mysql 에 접속 가능합니다.)
- ip : localhost
- port : 3306
- id : root
- password : 112233abc

