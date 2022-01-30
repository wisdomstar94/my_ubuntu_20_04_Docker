package main

import (
	"log"
	"os"
	"os/exec"
	"strings"
)

const initCheckFile string = "/golang/init_success.txt"
const initRootPassword string = "112233abc"

func main() {
	log.Println("db_init 시작")

	// mysql 실행 // bash 에서 직접 실행하는 걸로 변경
	// var _ = Command("service", "mysql", "start")

	// 최초 초기화 작업이 이루어졌는지 아닌지 체크
	if !isInit() {
		log.Println("init 되지 않음.. init 시작!")
		startInit()
	} else {
		log.Println("init 된 상태!")
	}
}

func startInit() {
	log.Println("startInit() 함수 호출됨!")

	// mysql 의 root 계정 비밀번호를 112233abc 으로 변경
	var result2 = Command("mysql", "-e", SumString([]string{
		SumString([]string{"set password=password('", initRootPassword, "');"}, ""),
		"FLUSH PRIVILEGES;",
	}, ""))
	log.Println("result2", result2)

	// mysql 의 계정 추가
	var result3 = Command("mysql", "-e", SumString([]string{
		SumString([]string{"CREATE USER 'root'@'172.17.0.1' IDENTIFIED BY '", initRootPassword, "';"}, ""),
		SumString([]string{"GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.17.0.1' IDENTIFIED BY '", initRootPassword, "' WITH GRANT OPTION;"}, ""),
		"FLUSH PRIVILEGES;",
	}, ""))
	log.Println("result3", result3)

	// 폴더 생성 (이미 존재하는 폴더면 생성하지 않음)
	CreateFolder("/golang")

	// 파일 생성 (이미 존재하는 파일이면 생성하지 않음)
	CreateFile(initCheckFile)
}

func isInit() bool {
	var isInit = IsFileOrFolderExist(initCheckFile)
	return isInit
}

func Command(command string, arg ...string) string {
	cmd := exec.Command(command, arg...)
	output, err := cmd.Output()
	if err != nil {
		log.Println("Command Error :", err)
		return "COMMAND_ERROR"
	} else {
		log.Println("Command Result", string(output))
		return string(output)
	}
}

func SumString(v []string, seperator string) string {
	return strings.Join(v, seperator)
}

func IsFileOrFolderExist(fullPath string) bool {
	log.Println("IsFileOrFolderExist 함수 호출됨.. fullPath=", fullPath)
	if _, err := os.Stat(fullPath); os.IsNotExist(err) {
		log.Println("err", err)
		return false
	}
	return true
}

func CreateFolder(folderPath string) bool {
	log.Println("CreateFolder 함수 호출됨.. folderPath=", folderPath)
	if IsFileOrFolderExist(folderPath) {
		return false
	}

	// Command("mkdir", folderPath)
	err := os.Mkdir(folderPath, 0755)
	if err != nil {
		log.Println(err)
		return false
	}
	return true
}

func CreateFile(filePath string) bool {
	log.Println("CreateFile 함수 호출됨.. filePath=", filePath)

	if IsFileOrFolderExist(filePath) {
		return false
	}

	_, err := os.Create(filePath)
	if err != nil {
		log.Println(err)
	}
	return true
}
