#!/bin/bash

# 引入ssh_connect.sh
ssh_connect_file="./ssh_connect.sh"

#
print_usage() {
    echo "用法: $0 <用户名@主机地址>"
    echo "选项:"
    echo "  -h         显示帮助信息"
    echo "  -c         清空密码文件"
    echo "  -d         删除指定目标的密码"
    exit 1
}

main() {

    # 检查传入的参数是否为空
    if [ -z "$1" ]; then
        print_usage
    fi

    # 获取目标主机（第一个参数）
    TARGET="$1"
    USER=$(echo "$TARGET" | cut -d'@' -f1)
    HOST=$(echo "$TARGET" | cut -d'@' -f2)

    # 解析命令行参数
    while getopts "hcd" opt; do
        case "$opt" in
        h) print_usage ;;
        c)
            clear_passwords
            "$ssh_connect_file" -c
            exit 0
            ;;
        # 调用脚本删除密码
        d)
            delete_password
            "$ssh_connect_file" -d "$TARGET"
            exit 0
            ;;
        *) print_usage ;;
        esac
    done

    # 检测SSH连接是否成功
    if "$ssh_connect_file" "$TARGET"; then
        printf "\033]0;%s@%s\007" "$USER" "$HOST"
    fi

}

#
main "$@"
